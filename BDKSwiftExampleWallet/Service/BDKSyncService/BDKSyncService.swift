//
//  BDKService2.swift
//  BDKSwiftExampleWallet
//
//  Created by Rubens Machion on 16/05/25.
//

import BitcoinDevKit
import Foundation

protocol BDKSyncService {
    var connection: Connection? { get }
    var keyClient: KeyClient { get }
    var network: Network { get }
    var wallet: Wallet? { get }
    var needsFullScan: Bool { get }
    
    func createWallet(params: String?) throws
    func loadWallet() throws
    func deleteWallet() throws
    
    func updateNetwork(network: Network)
    func updateEsploraURL(_ url: String)
}

extension BDKSyncService {
    func buildWallet(params: String?) throws -> Wallet {
        guard let newConnection = self.connection == nil ?
                try Connection.createConnection() :
                    self.connection else {
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
            connection: newConnection
        )
        
        return wallet
    }
    
    func buildBackupInfo(params: String) throws -> BackupInfo {
        if isXPub(params) {
            let descriptorPublicKey = try DescriptorPublicKey.fromString(publicKey: params)
            let fingerprint = descriptorPublicKey.masterFingerprint()
            let descriptor = Descriptor.newBip84Public(
                publicKey: descriptorPublicKey,
                fingerprint: fingerprint,
                keychain: .external,
                network: network
            )
            let changeDescriptor = Descriptor.newBip84Public(
                publicKey: descriptorPublicKey,
                fingerprint: fingerprint,
                keychain: .internal,
                network: network
            )
            return .init(
                mnemonic: "",
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
                mnemonic: "",
                descriptor: descriptor.description,
                changeDescriptor: changeDescriptor.description
            )
        }
        
        guard let mnemonic = try? Mnemonic.fromString(mnemonic: params) else {
            throw AppError.generic(message: "Invalid mnemonic")
        }
        let secretKey = DescriptorSecretKey(
            network: network,
            mnemonic: mnemonic,
            password: nil
        )
        let descriptor = Descriptor.newBip84(
            secretKey: secretKey,
            keychain: .external,
            network: network
        )
        let changeDescriptor = Descriptor.newBip84(
            secretKey: secretKey,
            keychain: .internal,
            network: network
        )
        return .init(
            mnemonic: mnemonic.description,
            descriptor: descriptor.description,
            changeDescriptor: changeDescriptor.description
        )
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
        let backupInfo = try keyClient.getBackupInfo()
        let descriptor = try Descriptor(descriptor: backupInfo.descriptor, network: self.network)
        let changeDescriptor = try Descriptor(
            descriptor: backupInfo.changeDescriptor,
            network: self.network
        )
        
        try FileManager.default.ensureDirectoryExists(at: URL.walletDataDirectoryURL)
        try FileManager.default.removeOldFlatFileIfNeeded(at: URL.defaultWalletDirectory)
        let persistenceBackendPath = URL.persistenceBackendPath
        let connection = try Connection(path: persistenceBackendPath)

        let wallet = try Wallet.load(
            descriptor: descriptor,
            changeDescriptor: changeDescriptor,
            connection: connection
        )
        
        return wallet
    }
    
    // MARK: - Optionals methods
    
    func updateEsploraURL(_ url: String) {
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
