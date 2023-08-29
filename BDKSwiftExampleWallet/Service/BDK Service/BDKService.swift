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
        let txBuilder = try buildTransaction(address: address, amount: amount, feeRate: feeRate)
        // showFee()
        try signAndBroadcast(txBuilder: txBuilder)
    }

    private func buildTransaction(address: String, amount: UInt64, feeRate: Float?) throws
        -> TxBuilderResult
    {
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

struct BDKClient {
    let loadWallet: () throws -> Void
    let deleteWallet: () throws -> Void
    let createWallet: () throws -> Void
    let getBalance: () throws -> Balance
    let getTransactions: () throws -> [TransactionDetails]
    let sync: () async throws -> Void
    let getAddress: () throws -> String
    let send: (String, UInt64, Float?) throws -> Void
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
        }
    )
}

#if DEBUG
    let mockBalance = Balance(
        immature: 0,
        trustedPending: 0,
        untrustedPending: 0,
        confirmed: 21_418_468,
        spendable: 21_418_468,
        total: 21_418_468
    )
    let mockBalanceZero = Balance(
        immature: 0,
        trustedPending: 0,
        untrustedPending: 0,
        confirmed: 21_418_468,
        spendable: 0,
        total: 0
    )
    let mockTransactionDetails =
        [
            BitcoinDevKit.TransactionDetails(
                transaction: nil,
                fee: Optional(2820),
                received: 10_000_000,
                sent: 0,
                txid: "cdcc4d287e4780d25c577d4f5726c7d585625170559f0b294da20b55ffa2b009",
                confirmationTime: Optional(
                    BitcoinDevKit.BlockTime(height: 178497, timestamp: 1_687_465_081)
                )
            ),
            BitcoinDevKit.TransactionDetails(
                transaction: nil,
                fee: Optional(2820),
                received: 100000,
                sent: 0,
                txid: "1cd378b13f6c9ed506ef6c24337da7a36950b0b4611af070d6636ccc408f3130",
                confirmationTime: Optional(
                    BitcoinDevKit.BlockTime(height: 357327, timestamp: 1_693_053_486)
                )
            ),
            BitcoinDevKit.TransactionDetails(
                transaction: nil,
                fee: Optional(2820),
                received: 100000,
                sent: 0,
                txid: "4da9ebbb7438c5a27ee6a219d2c7568c33b4ccc0d49d9d43960227de7c7beb34",
                confirmationTime: Optional(
                    BitcoinDevKit.BlockTime(height: 213729, timestamp: 1_688_565_953)
                )
            ),
            BitcoinDevKit.TransactionDetails(
                transaction: nil,
                fee: Optional(141),
                received: 6250,
                sent: 0,
                txid: "68a1262ddbf1ce0b840b0f06429a8df04a4474e275a8707ec3e2a432b7178f44",
                confirmationTime: Optional(
                    BitcoinDevKit.BlockTime(height: 269233, timestamp: 1_690_301_719)
                )
            ),
            BitcoinDevKit.TransactionDetails(
                transaction: nil,
                fee: Optional(141),
                received: 74859,
                sent: 100000,
                txid: "6d65a5e57df85221b2c4c882e69de36ac775e57c044ffe19721a456597701459",
                confirmationTime: Optional(
                    BitcoinDevKit.BlockTime(height: 269189, timestamp: 1_690_300_353)
                )
            ),
            BitcoinDevKit.TransactionDetails(
                transaction: nil,
                fee: Optional(2820),
                received: 10_000_000,
                sent: 0,
                txid: "cddb6950ac9ac03fde059019389cc5be1f399852d5ce073a3d4d1fbb544d5f62",
                confirmationTime: Optional(
                    BitcoinDevKit.BlockTime(height: 172976, timestamp: 1_687_292_803)
                )
            ),
            BitcoinDevKit.TransactionDetails(
                transaction: nil,
                fee: Optional(2820),
                received: 1_000_000,
                sent: 0,
                txid: "320959113997ee8d9b3766d3022183e206d75646f018010b5bc87b816978257d",
                confirmationTime: Optional(
                    BitcoinDevKit.BlockTime(height: 172962, timestamp: 1_687_292_372)
                )
            ),
            BitcoinDevKit.TransactionDetails(
                transaction: nil,
                fee: Optional(2820),
                received: 100000,
                sent: 0,
                txid: "47b7b72f297c260c243ae0a7474554c709b8ea3a7090c8353e0828a9107e2cb3",
                confirmationTime: Optional(
                    BitcoinDevKit.BlockTime(height: 172955, timestamp: 1_687_292_152)
                )
            ),
            BitcoinDevKit.TransactionDetails(
                transaction: nil,
                fee: Optional(141),
                received: 50000,
                sent: 0,
                txid: "d639021c55ba7d4c2d7a15b9bda74eb7d7de3fac8c7395e6c6cbb1ff5d6541b7",
                confirmationTime: Optional(
                    BitcoinDevKit.BlockTime(height: 269162, timestamp: 1_690_299_514)
                )
            ),
            BitcoinDevKit.TransactionDetails(
                transaction: nil,
                fee: Optional(2820),
                received: 100000,
                sent: 0,
                txid: "bd83e380361e3adacea03088bc0843a6c3ec87601edaa197141fc512cd343dc2",
                confirmationTime: Optional(
                    BitcoinDevKit.BlockTime(height: 173003, timestamp: 1_687_293_647)
                )
            ),
            BitcoinDevKit.TransactionDetails(
                transaction: nil,
                fee: Optional(141),
                received: 87359,
                sent: 100000,
                txid: "2ad94edbd9b4f2794d731ec660b0f1076ed287cfee198333f7035d5861f6abe8",
                confirmationTime: Optional(
                    BitcoinDevKit.BlockTime(height: 269197, timestamp: 1_690_300_599)
                )
            ),
        ]
    let mockTransactionDetailsZero: [TransactionDetails] = []
    extension BDKClient {
        static let mock = Self(
            loadWallet: {},
            deleteWallet: {},
            createWallet: {},
            getBalance: { mockBalance },
            getTransactions: { mockTransactionDetails },
            sync: {},
            getAddress: { "mockAddress" },
            send: { _, _, _ in }
        )
        static let mockZero = Self(
            loadWallet: {},
            deleteWallet: {},
            createWallet: {},
            getBalance: { mockBalanceZero },
            getTransactions: { mockTransactionDetailsZero },
            sync: {},
            getAddress: { "mockAddress" },
            send: { _, _, _ in }
        )
    }
#endif
