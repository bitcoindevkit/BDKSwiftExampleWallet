//
//  BDKService2.swift
//  BDKSwiftExampleWallet
//
//  Created by Rubens Machion on 16/05/25.
//

import BitcoinDevKit
import Foundation

typealias FullScanProgress = (UInt64) -> Void
typealias SyncScanProgress = (UInt64, UInt64) -> Void

protocol BDKSyncService {
    var connection: Connection? { get }
    var keyClient: KeyClient { get }
    var network: Network { get }
    var wallet: Wallet? { get }
    
    func createWallet(params: String?) throws
    func loadWallet() throws
    func deleteWallet() throws    
    func startSync(progress: @escaping SyncScanProgress) async throws
    func startFullScan(progress: @escaping FullScanProgress) async throws
    
    func updateNetwork(network: Network)
    func updateEsploraURL(_ url: String)
    
    func getTransactions() throws -> [CanonicalTx]
    func getBalance() throws -> Balance
    func sentAndReceived(tx: Transaction) throws -> SentAndReceivedValues
    func calculateFeeRate(tx: Transaction) throws -> UInt64
    func calculateFee(tx: Transaction) throws -> Amount
    func buildTransaction(address: String, amount: UInt64, feeRate: UInt64) throws -> Psbt
    func send(address: String, amount: UInt64, feeRate: UInt64) async throws
    func listUnspent() throws -> [LocalOutput]
    func getAddress() throws -> String
}

extension BDKSyncService {
    func buildWallet(params: String?) throws -> Wallet {
        guard let connection = self.connection else {
            throw WalletError.dbNotFound
        }
        
        let backupInfo = try buildBackupInfo(params: params ?? Mnemonic(wordCount: WordCount.words12).description)

        try keyClient.saveBackupInfo(backupInfo)
        try keyClient.saveNetwork(self.network.description)

        let descriptor = try Descriptor(descriptor: backupInfo.descriptor, network: network)
        let changeDescriptor = try Descriptor(descriptor: backupInfo.changeDescriptor, network: network)
        
        let wallet = try Wallet(
            descriptor: descriptor,
            changeDescriptor: changeDescriptor,
            network: network,
            connection: connection
        )
        
        return wallet
    }
    
    func buildBackupInfo(params: String) throws -> BackupInfo {
        if isXPub(params) {
            let descriptorPublicKey = try DescriptorPublicKey.fromString(publicKey: params)
            let fingerprint = descriptorPublicKey.masterFingerprint()
            let descriptor = Descriptor.newBip86Public(
                publicKey: descriptorPublicKey,
                fingerprint: fingerprint,
                keychain: .external,
                network: network
            )
            let changeDescriptor = Descriptor.newBip86Public(
                publicKey: descriptorPublicKey,
                fingerprint: fingerprint,
                keychain: .internal,
                network: network
            )
            return .init(
                descriptor: descriptor.description,
                changeDescriptor: changeDescriptor.description
            )
        }
        
        if isDescriptor(params) { // is a descriptor?
            
            let descriptorStrings = params.components(separatedBy: "\n")
                .map { $0.split(separator: "#").first?.trimmingCharacters(in: .whitespaces) ?? "" }
                .filter { !$0.isEmpty }
            let descriptor: Descriptor
            let changeDescriptor: Descriptor
            
            if descriptorStrings.count == 1 {
                let parsedDescriptor = try Descriptor(
                    descriptor: descriptorStrings[0],
                    network: network
                )
                let singleDescriptors = try parsedDescriptor.toSingleDescriptors()
                guard singleDescriptors.count >= 2 else {
                    throw AppError.generic(message: "Too many output descriptors to parse")
                }
                descriptor = singleDescriptors[0]
                changeDescriptor = singleDescriptors[1]
            } else if descriptorStrings.count == 2 {
                descriptor = try Descriptor(descriptor: descriptorStrings[0], network: network)
                changeDescriptor = try Descriptor(descriptor: descriptorStrings[1], network: network)
            } else {
                throw AppError.generic(message: "Descriptor parsing failed")
            }
            
            return .init(
                descriptor: descriptor.toStringWithSecret(),
                changeDescriptor: changeDescriptor.toStringWithSecret()
            )
        }
        
        let words = !params.isEmpty ? params : Mnemonic(wordCount: WordCount.words12).description
        guard let mnemonic = try? Mnemonic.fromString(mnemonic: words) else {
            throw AppError.generic(message: "Invalid mnemonic")
        }
        let secretKey = DescriptorSecretKey(
            network: network,
            mnemonic: mnemonic,
            password: nil
        )
        let descriptor = Descriptor.newBip86(
            secretKey: secretKey,
            keychain: .external,
            network: network
        )
        let changeDescriptor = Descriptor.newBip86(
            secretKey: secretKey,
            keychain: .internal,
            network: network
        )
        return .init(
            mnemonic: mnemonic.description,
            descriptor: descriptor.toStringWithSecret(),
            changeDescriptor: changeDescriptor.toStringWithSecret()
        )
    }
    
    func deleteWallet() throws {
        try deleteData()
    }
    
    func deleteData() throws {
        do {
            try keyClient.deleteAllData()
            
            if let bundleID = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: bundleID)
            }
            
            let walletDataDirectoryURL = URL.walletDataDirectoryURL
            if FileManager.default.fileExists(atPath: walletDataDirectoryURL.path) {
                try FileManager.default.removeItem(at: walletDataDirectoryURL)
            }
            
        } catch {
            throw AppError.generic(message: "Failed to remove Keychain data")
        }
    }
    
    func loadWalleFromBackup() throws -> Wallet {
        guard let connection = self.connection else {
            throw WalletError.dbNotFound
        }
        
        let backupInfo = try keyClient.getBackupInfo()
        let descriptor = try Descriptor(descriptor: backupInfo.descriptor, network: self.network)
        let changeDescriptor = try Descriptor(
            descriptor: backupInfo.changeDescriptor,
            network: self.network
        )
        let wallet = try Wallet.load(
            descriptor: descriptor,
            changeDescriptor: changeDescriptor,
            connection: connection
        )
        
        return wallet
    }
    
    func getBalance() throws -> Balance {
        guard let wallet = self.wallet else { throw WalletError.walletNotFound }
        let balance = wallet.balance()
        return balance
    }
    
    func sentAndReceived(tx: Transaction) throws -> SentAndReceivedValues {
        guard let wallet = self.wallet else {
            throw WalletError.walletNotFound
        }
        let values = wallet.sentAndReceived(tx: tx)
        return values
    }
    
    func calculateFeeRate(tx: Transaction) throws -> UInt64 {
        guard let wallet = self.wallet else {
            throw WalletError.walletNotFound
        }
        let feeRate = try wallet.calculateFeeRate(tx: tx)
        return feeRate.toSatPerVbCeil()
    }
    
    func calculateFee(tx: Transaction) throws -> Amount {
        guard let wallet = self.wallet else {
            throw WalletError.walletNotFound
        }
        let fee = try wallet.calculateFee(tx: tx)
        return fee
    }
    
    func buildTransaction(
        address: String,
        amount: UInt64,
        feeRate: UInt64
    ) throws -> Psbt {
        guard let wallet = self.wallet else { throw WalletError.walletNotFound }
        let script = try Address(address: address, network: self.network)
            .scriptPubkey()
        let txBuilder = try TxBuilder()
            .addRecipient(
                script: script,
                amount: Amount.fromSat(satoshi: amount)
            )
            .feeRate(feeRate: FeeRate.fromSatPerVb(satVb: feeRate))
            .finish(wallet: wallet)
        return txBuilder
    }
    
    func listUnspent() throws -> [LocalOutput] {
        guard let wallet = self.wallet else {
            throw WalletError.walletNotFound
        }
        let localOutputs = wallet.listUnspent()
        return localOutputs
    }
    
    func getAddress() throws -> String {
        guard let wallet = self.wallet else {
            throw WalletError.walletNotFound
        }
        guard let connection = self.connection else {
            throw WalletError.dbNotFound
        }
        let addressInfo = wallet.revealNextAddress(keychain: .external)
        let _ = try wallet.persist(connection: connection)
        return addressInfo.address.description
    }
    
    func getTransactions() throws -> [CanonicalTx] {
        guard let wallet = self.wallet else {
            throw WalletError.walletNotFound
        }
        let transactions = wallet.transactions()
        let sortedTransactions = transactions.sorted { (tx1, tx2) in
            return tx1.chainPosition.isBefore(tx2.chainPosition)
        }
        return sortedTransactions
    }
    
    // MARK: - Optionals methods
    
    func updateEsploraURL(_ url: String) {
        // Optional implementation
    }
    
    func updateNetwork(network: Network) {
        // Optional implementation
    }
    
    // MARK: - Private
    
    private func isDescriptor(_ param: String) -> Bool {
        param.hasPrefix("tr(") ||
        param.hasPrefix("wpkh(") ||
        param.hasPrefix("wsh(") ||
        param.hasPrefix("sh(")
    }
    
    private func isXPub(_ param: String) -> Bool {
        param.hasPrefix("xpub") || param.hasPrefix("tpub") || param.hasPrefix("vpub") || param.hasPrefix("zpub")
    }
}
