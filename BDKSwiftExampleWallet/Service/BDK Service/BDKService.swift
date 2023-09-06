//
//  BDKService.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 5/23/23.
//

import BitcoinDevKit
import Foundation

private class BDKService {
    private var balance: Balance?
    private var blockchainConfig: BlockchainConfig?
    var network: Network = .signet
    private var wallet: Wallet?
    private let keyService: KeyClient

    class var shared: BDKService {
        struct Singleton {
            static let instance = BDKService()
        }
        return Singleton.instance
    }

    init(keyService: KeyClient = .live) {
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
        let mnemonicWords12 =
            "space echo position wrist orient erupt relief museum myself grain wisdom tumble"
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
        try keyService.saveBackupInfo(backupInfo)
        let wallet = try Wallet(
            descriptor: descriptor,
            changeDescriptor: changeDescriptor,
            network: network,
            databaseConfig: .memory
        )
        self.wallet = wallet
    }

    private func loadWallet(descriptor: Descriptor, changeDescriptor: Descriptor) throws {
        let wallet = try Wallet(
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
        let changeDescriptor = try Descriptor(
            descriptor: backupInfo.changeDescriptor,
            network: self.network
        )
        try self.loadWallet(descriptor: descriptor, changeDescriptor: changeDescriptor)
    }

    func deleteWallet() throws {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        try self.keyService.deleteBackupInfo()
    }

    func send(address: String, amount: UInt64, feeRate: Float?) throws {
        print(
            "BDKService - send \n address: \(address) \n amount \(amount) \n feeRate \(String(describing: feeRate))"
        )
        let txBuilder = try buildTransaction(address: address, amount: amount, feeRate: feeRate)
        // showFee()
        try signAndBroadcast(txBuilder: txBuilder)
    }

    func buildTransaction(address: String, amount: UInt64, feeRate: Float?) throws  // private
        -> TxBuilderResult
    {
        guard let wallet = self.wallet else { throw WalletError.walletNotFound }
        let script = try Address(address: address)
            .scriptPubkey()
        let txBuilder = try TxBuilder()
            .addRecipient(script: script, amount: amount)
            .feeRate(satPerVbyte: feeRate ?? 1.0)
            .finish(wallet: wallet)
        print("BDKService - buildTransaction - txbuilder: \n \(txBuilder)")
        return txBuilder
    }

    private func signAndBroadcast(txBuilder: TxBuilderResult) throws {
        guard let wallet = self.wallet else { throw WalletError.walletNotFound }
        guard let config = blockchainConfig else { throw WalletError.blockchainConfigNotFound }
        let _ = try wallet.sign(psbt: txBuilder.psbt, signOptions: nil)

        let transaction = txBuilder.psbt.extractTx()
        print("BDKService - signAndBroadcast \n transaction \(txBuilder)")

        print("BDKService - signAndBroadcast \n config \(config)")

        let blockchain = try Blockchain(config: config)
        print("BDKService - signAndBroadcast \n blockchain \(blockchain)")

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

struct BDKClient {
    let loadWallet: () throws -> Void
    let deleteWallet: () throws -> Void
    let createWallet: () throws -> Void
    let getBalance: () throws -> Balance
    let getTransactions: () throws -> [TransactionDetails]
    let sync: () async throws -> Void
    let getAddress: () throws -> String
    let send: (String, UInt64, Float?) throws -> Void
    let buildTransaction: (String, UInt64, Float?) throws -> TxBuilderResult
}

extension BDKClient {
    static let live = Self(
        loadWallet: { try BDKService.shared.loadWalletFromBackup() },
        deleteWallet: { try BDKService.shared.deleteWallet() },
        createWallet: { try BDKService.shared.createWallet() },
        getBalance: { try BDKService.shared.getBalance() },
        getTransactions: { try BDKService.shared.getTransactions() },
        sync: { try await BDKService.shared.sync() },
        getAddress: { try BDKService.shared.getAddress() },
        send: { (address, amount, feeRate) in
            try BDKService.shared.send(address: address, amount: amount, feeRate: feeRate)
        },
        buildTransaction: { (address, amount, feeRate) in
            try BDKService.shared.buildTransaction(
                address: address,
                amount: amount,
                feeRate: feeRate
            )
        }
    )
}

#if DEBUG
    extension BDKClient {
        static let mock = Self(
            loadWallet: {},
            deleteWallet: {},
            createWallet: {},
            getBalance: { mockBalance },
            getTransactions: { mockTransactionDetails },
            sync: {},
            getAddress: { "mockAddress" },
            send: { _, _, _ in },
            buildTransaction: { _, _, _ in
                return try! TxBuilderResult(
                    psbt: .init(psbtBase64: "psbtBase64"),
                    transactionDetails: mockTransactionDetail
                )
            }
        )
        static let mockZero = Self(
            loadWallet: {},
            deleteWallet: {},
            createWallet: {},
            getBalance: { mockBalanceZero },
            getTransactions: { mockTransactionDetailsZero },
            sync: {},
            getAddress: { "mockAddress" },
            send: { _, _, _ in },
            buildTransaction: { _, _, _ in
                return try! TxBuilderResult(
                    psbt: .init(psbtBase64: "psbtBase64"),
                    transactionDetails: mockTransactionDetail
                )
            }
        )
    }
#endif
