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
    private var network: Network = .signet
    private var wallet: Wallet?
    
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
        self.getWallet()
    }
    
    func getAddress() throws -> String {
        guard let wallet = self.wallet else {
            throw WalletError.walletNotFound
        }
        let addressInfo = try wallet.getAddress(addressIndex: .lastUnused)
        return addressInfo.address.asString()
    }
    
    func getBalance() throws -> Balance {
        guard let wallet = self.wallet else { throw WalletError.walletNotFound }
        let balance = try wallet.getBalance()
        return balance
    }
    
    private func getWallet() {
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
            let wallet = try Wallet.init(
                descriptor: descriptor,
                changeDescriptor: changeDescriptor,
                network: network,
                databaseConfig: .memory
            )
            self.wallet = wallet
        } catch {
            print("BDKService getWallet error: \(error.localizedDescription)")
        }
    }
    
    func getTransactions() throws -> [TransactionDetails] {
        guard let wallet = self.wallet else { throw WalletError.walletNotFound }
        let transactionDetails = try wallet.listTransactions(includeRaw: false)
        return transactionDetails
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
