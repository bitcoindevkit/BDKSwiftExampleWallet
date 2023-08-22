//
//  BDKService.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 5/23/23.
//

import Foundation
import BitcoinDevKit

class BDKService {
    private var balance: Balance?
    private var blockchainConfig: BlockchainConfig?
    var network: Network = .signet
    private var wallet: Wallet?
    private let keyService: KeyService

    
    class var shared: BDKService {
        struct Singleton {
            static let instance = BDKService(keyService: .init())
        }
        return Singleton.instance
    }
    
    init(keyService: KeyService) {
        let esploraConfig = EsploraConfig(
            baseUrl: Constants.Config.EsploraServerURLNetwork.signet,
            proxy: nil,
            concurrency: nil,
            stopGap: UInt64(20),
            timeout: nil
        )
        let blockchainConfig = BlockchainConfig.esplora(config: esploraConfig)
        self.blockchainConfig = blockchainConfig
        self.keyService = keyService
    }
    
    func getAddress() throws -> String {
        guard let wallet = self.wallet else {
            throw WalletError.walletNotFound
        }
        let addressInfo = try wallet.getAddress(addressIndex: .new)
        return addressInfo.address.asString()
    }
    
    func getBalance() throws -> Balance {
        guard let wallet = self.wallet else { throw WalletError.walletNotFound }
        let balance = try wallet.getBalance()
        return balance
    }
    
    func getTransactions() throws -> [TransactionDetails] {
        guard let wallet = self.wallet else { throw WalletError.walletNotFound }
        let transactionDetails = try wallet.listTransactions(includeRaw: false)
        return transactionDetails
    }
    
    func createWallet() throws {
        let mnemonicWords12 = "space echo position wrist orient erupt relief museum myself grain wisdom tumble"
        let mnemonic = try Mnemonic.fromString(mnemonic: mnemonicWords12)
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
        let backupInfo = BackupInfo(
            mnemonic: mnemonic.asString(),
            descriptor: descriptor.asString(),
            changeDescriptor: changeDescriptor.asStringPrivate()
        )
        try keyService.saveBackupInfo(backupInfo: backupInfo)
        let wallet = try Wallet.init(
            descriptor: descriptor,
            changeDescriptor: changeDescriptor,
            network: network,
            databaseConfig: .memory
        )
        self.wallet = wallet
    }
    
    private func loadWallet(descriptor: Descriptor, changeDescriptor: Descriptor) throws {
        let wallet = try Wallet.init(
            descriptor: descriptor,
            changeDescriptor: changeDescriptor,
            network: network,
            databaseConfig: .memory
        )
        self.wallet = wallet
    }
    
    func loadWalletFromBackup() throws {
        let backupInfo = try keyService.getBackupInfo()
        let descriptor = try Descriptor(descriptor: backupInfo.descriptor, network: self.network)
        let changeDescriptor = try Descriptor(descriptor: backupInfo.changeDescriptor, network: self.network)
        try self.loadWallet(descriptor: descriptor, changeDescriptor: changeDescriptor)
    }
    
    func deleteWallet() throws {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        try self.keyService.deleteBackupInfo()
    }
    
    func send(address: String, amount: UInt64, feeRate: Float?) throws {
        let txBuilder = try buildTransaction(address: address, amount: amount, feeRate: feeRate)
        // showFee()
        try signAndBroadcast(txBuilder: txBuilder)
    }
    
    private func buildTransaction(address: String, amount: UInt64, feeRate: Float?) throws -> TxBuilderResult {
        guard let wallet = self.wallet else { throw WalletError.walletNotFound }
        let script = try Address(address: address)
            .scriptPubkey()
        let txBuilder = try TxBuilder()
            .addRecipient(script: script, amount: amount)
            .feeRate(satPerVbyte: feeRate ?? 1.0)
            .finish(wallet: wallet)
        return txBuilder
    }
    
    private func showFee() {
        // TODO: let result = txBuilder.transactionDetails.fee
    }
    
    private func signAndBroadcast(txBuilder: TxBuilderResult) throws {
        guard let wallet = self.wallet else { throw WalletError.walletNotFound }
        guard let config = blockchainConfig else { throw WalletError.blockchainConfigNotFound }
        let _ = try wallet.sign(psbt: txBuilder.psbt, signOptions: nil)
        let transaction = txBuilder.psbt.extractTx()
        let blockchain = try Blockchain(config: config)
        try blockchain.broadcast(transaction: transaction)
    }
    
    func sync() async throws {
        guard let config = self.blockchainConfig else {
            throw WalletError.blockchainConfigNotFound
        }
        guard let wallet = self.wallet else {
            throw WalletError.walletNotFound
        }
        let blockchain = try Blockchain(config: config)
        try wallet.sync(blockchain: blockchain, progress: nil)
    }
    
}
