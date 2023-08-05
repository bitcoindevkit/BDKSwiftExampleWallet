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
    var wallet: Wallet?
    private var keyData: KeyData?
    
    class var shared: BDKService {
        struct Singleton {
            static let instance = BDKService()
        }
        return Singleton.instance
    }
    
    init() {
        let esploraConfig = EsploraConfig(
            baseUrl: Constants.Config.EsploraServerURLNetwork.signet,
            proxy: nil,
            concurrency: nil,
            stopGap: UInt64(20),
            timeout: nil
        )
        let blockchainConfig = BlockchainConfig.esplora(config: esploraConfig)
        self.blockchainConfig = blockchainConfig
//        self.getWallet()
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
    
//    private func getWallet() {
//        let mnemonicWords12 = "space echo position wrist orient erupt relief museum myself grain wisdom tumble"
//        do {
//            let mnemonic = try Mnemonic.fromString(mnemonic: mnemonicWords12)
//            let secretKey = DescriptorSecretKey(
//                network: network,
//                mnemonic: mnemonic,
//                password: nil
//            )
//            let descriptor = Descriptor.newBip84(
//                secretKey: secretKey,
//                keychain: .external,
//                network: network
//            )
//            let changeDescriptor = Descriptor.newBip84(
//                secretKey: secretKey,
//                keychain: .internal,
//                network: network
//            )
//            let wallet = try Wallet.init(
//                descriptor: descriptor,
//                changeDescriptor: changeDescriptor,
//                network: network,
//                databaseConfig: .memory
//            )
//            self.wallet = wallet
//        } catch {
//            print("BDKService getWallet error: \(error.localizedDescription)")
//        }
//    }
    
    func createWallet() {
        let mnemonicWords12 = "space echo position wrist orient erupt relief museum myself grain wisdom tumble"
        do {
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
//            let wallet = try Wallet.init(
//                descriptor: descriptor,
//                changeDescriptor: changeDescriptor,
//                network: network,
//                databaseConfig: .memory
//            )
//            self.wallet = wallet
            let keyData = KeyData(mnemonic: mnemonic.asString(), descriptor: descriptor.asString(), changeDescriptor: changeDescriptor.asStringPrivate()) // what is asStringPrivate again?
            try KeyService().saveKeyData(keyData: keyData)
            self.keyData = keyData
            
            let wallet = try Wallet.init(
                descriptor: descriptor,
                changeDescriptor: changeDescriptor,
                network: network,
                databaseConfig: .memory
            )
            self.wallet = wallet
            
        } catch {
            print("BDKService createWallet error: \(error.localizedDescription)")
        }
    }
    
    func loadWallet(descriptor: Descriptor, changeDescriptor: Descriptor) {
        do {
            let wallet = try Wallet.init(
                descriptor: descriptor,
                changeDescriptor: changeDescriptor,
                network: network,
                databaseConfig: .memory
            )
            self.wallet = wallet
        } catch {
            print("BDKService loadWallet error: \(error.localizedDescription)")
        }
    }
    
    func send(address: String, amount: UInt64, feeRate: Float?) throws {
        guard let wallet = self.wallet else { throw WalletError.walletNotFound }
        guard let config = blockchainConfig else { throw WalletError.blockchainConfigNotFound }
        let script = try Address(address: address)
            .scriptPubkey()
        let txBuilder = try TxBuilder()
            .addRecipient(script: script, amount: amount)
            .feeRate(satPerVbyte: feeRate ?? 1.0)
            .finish(wallet: wallet)
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
