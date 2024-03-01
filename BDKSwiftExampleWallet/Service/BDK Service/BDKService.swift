//
//  BDKService.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 5/23/23.
//

import BitcoinDevKit
import Foundation

private class BDKService {
    static var shared: BDKService = BDKService()
    private var balance: Balance?
    //private var blockchainConfig: BlockchainConfig?
    var network: Network
    private var wallet: Wallet?
    private let keyService: KeyClient

    init(
        keyService: KeyClient = .live
    ) {
        let storedNetworkString = try! keyService.getNetwork() ?? Network.testnet.description
        let storedEsploraURL =
            try! keyService.getEsploraURL()
            ?? Constants.Config.EsploraServerURLNetwork.Testnet.mempoolspace

        self.network = Network(stringValue: storedNetworkString) ?? .testnet
        self.keyService = keyService

//        let esploraConfig = EsploraConfig(
//            baseUrl: storedEsploraURL,
//            proxy: nil,
//            concurrency: nil,
//            stopGap: UInt64(20),
//            timeout: nil
//        )
//        let blockchainConfig = BlockchainConfig.esplora(config: esploraConfig)
//        self.blockchainConfig = blockchainConfig
    }

    func getAddress() throws -> String {
        guard let wallet = self.wallet else {
            throw WalletError.walletNotFound
        }
        let addressInfo =  wallet.getAddress(addressIndex: .new) // try
        return addressInfo.address.asString()
    }

    func getBalance() throws -> Balance {
        guard let wallet = self.wallet else { throw WalletError.walletNotFound }
        let balance =  wallet.getBalance() // try
        return balance
    }

//    func getTransactions() throws -> [TransactionDetails] {
//        guard let wallet = self.wallet else { throw WalletError.walletNotFound }
//        let transactionDetails = try wallet.listTransactions(includeRaw: false)
//        return transactionDetails
//    }
    
    func transactions() throws -> [Transaction] {
        guard let wallet = self.wallet else {
            throw WalletError.walletNotFound
        }
        let transactions = wallet.transactions()
        return transactions
    }

    func createWallet(words: String?) throws {

        let baseUrl =
            try! keyService.getEsploraURL()
            ?? Constants.Config.EsploraServerURLNetwork.Testnet.mempoolspace
//        let esploraConfig = EsploraConfig(
//            baseUrl: baseUrl,
//            proxy: nil,
//            concurrency: nil,
//            stopGap: UInt64(20),
//            timeout: nil
//        )
//        let blockchainConfig = BlockchainConfig.esplora(config: esploraConfig)
//        self.blockchainConfig = blockchainConfig

        var words12: String
        if let words = words, !words.isEmpty {
            words12 = words
        } else {
            let mnemonic = Mnemonic(wordCount: WordCount.words12)
            words12 = mnemonic.asString()
        }
        let mnemonic = try Mnemonic.fromString(mnemonic: words12)
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
        let backupInfo = BackupInfo(
            mnemonic: mnemonic.asString(),
            descriptor: descriptor.asStringPrivate(),
            changeDescriptor: changeDescriptor.asStringPrivate()
        )
        try keyService.saveBackupInfo(backupInfo)
        try keyService.saveNetwork(self.network.description)
        try keyService.saveEsploraURL(baseUrl)
//        let wallet = try Wallet(
//            descriptor: descriptor,
//            changeDescriptor: changeDescriptor,
//            network: network,
//            databaseConfig: .memory
//        )
        
        let documentsDirectoryURL = BitcoinStorage().getDocumentsDirectory()
        let walletDataDirectoryURL = documentsDirectoryURL.appendingPathComponent("wallet_data")
        let persistenceBackendPath = walletDataDirectoryURL.path
        let wallet = try Wallet(
            descriptor: descriptor,
            changeDescriptor: changeDescriptor, 
            persistenceBackendPath: persistenceBackendPath,
            network: network
        )
        self.wallet = wallet
    }

    private func loadWallet(descriptor: Descriptor, changeDescriptor: Descriptor) throws {
//        let wallet = try Wallet(
//            descriptor: descriptor,
//            changeDescriptor: changeDescriptor,
//            network: network,
//            databaseConfig: .memory
//        )
        
        let documentsDirectoryURL = BitcoinStorage().getDocumentsDirectory()
        let walletDataDirectoryURL = documentsDirectoryURL.appendingPathComponent("wallet_data")
        let persistenceBackendPath = walletDataDirectoryURL.path
        let wallet = try Wallet(
            descriptor: descriptor,
            changeDescriptor: changeDescriptor,
            persistenceBackendPath: persistenceBackendPath,
            network: network
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
        try self.keyService.deleteEsplora()
        try self.keyService.deleteNetwork()
    }

    func getBackupInfo() throws -> BackupInfo {
        let backupInfo = try keyService.getBackupInfo()
        return backupInfo
    }

//    func send(address: String, amount: UInt64, feeRate: Float?) throws {
//        let txBuilder = try buildTransaction(address: address, amount: amount, feeRate: feeRate)
//        try signAndBroadcast(txBuilder: txBuilder)
//    }
    
    func send(
        address: String,
        amount: UInt64,
        feeRate: Float?
    ) async throws {
        let psbt = try buildTransaction(
            address: address,
            amount: amount,
            feeRate: feeRate
        )
        try signAndBroadcast(psbt: psbt)
    }

//    func buildTransaction(address: String, amount: UInt64, feeRate: Float?) throws
//        -> TxBuilderResult
//    {
//        guard let wallet = self.wallet else { throw WalletError.walletNotFound }
//        let script = try Address(address: address, network: network)
//            .scriptPubkey()
//        let txBuilder = try TxBuilder()
//            .addRecipient(script: script, amount: amount)
//            .feeRate(satPerVbyte: feeRate ?? 1.0)
//            .finish(wallet: wallet)
//        return txBuilder
//    }
    
    func buildTransaction(address: String, amount: UInt64, feeRate: Float?) throws
         -> PartiallySignedTransaction
     {
         guard let wallet = self.wallet else { throw WalletError.walletNotFound }
         let script = try Address(address: address, network: self.network)
             .scriptPubkey()
         let txBuilder = try TxBuilder()
             .addRecipient(script: script, amount: amount)
             .feeRate(feeRate: FeeRate.fromSatPerVb(satPerVb: feeRate ?? 1.0))//.feeRate(satPerVbyte: feeRate ?? 1.0)
             .finish(wallet: wallet)
         return txBuilder
     }

//    private func signAndBroadcast(txBuilder: TxBuilderResult) throws {
//        guard let wallet = self.wallet else { throw WalletError.walletNotFound }
//        guard let config = blockchainConfig else { throw WalletError.blockchainConfigNotFound }
//        let _ = try wallet.sign(psbt: txBuilder.psbt, signOptions: nil)
//        let transaction = txBuilder.psbt.extractTx()
//        let blockchain = try Blockchain(config: config)
//        try blockchain.broadcast(transaction: transaction)
//    }
    private func signAndBroadcast(psbt: PartiallySignedTransaction) throws {
        guard let wallet = self.wallet else { throw WalletError.walletNotFound }
        let _ = try wallet.sign(psbt: psbt)
        let transaction = psbt.extractTx()
        let client = EsploraClient(url: "https://mutinynet.com/api")
        try client.broadcast(transaction: transaction)
        print("broadcast must have gone thru")
    }

//    func sync() async throws {
//        guard let config = self.blockchainConfig else {
//            throw WalletError.blockchainConfigNotFound
//        }
//        guard let wallet = self.wallet else {
//            throw WalletError.walletNotFound
//        }
//        let blockchain = try Blockchain(config: config)
//        try wallet.sync(blockchain: blockchain, progress: nil)
//    }
    func sync() async throws {
         guard let wallet = self.wallet else { throw WalletError.walletNotFound }
         let esploraClient = EsploraClient(url: "https://mutinynet.com/api")
        let syncRequest = wallet.syncRevealedSpksRequest()
         let update = try esploraClient.sync(
             request: syncRequest,
//             stopGap: UInt64(150), // should we default value this for folks?
             parallelRequests: UInt64(5) // should we default value this for folks?
         )
         let _ = try wallet.applyUpdate(update: update)
         let isChanged = try wallet.commit()
         // TODO: Do i need to do this next step of setting wallet to wallet again?
         // prob not
         self.wallet = wallet
     }
    
//    func sync() async throws {
//         guard let wallet = self.wallet else { throw WalletError.walletNotFound }
//         let esploraClient = EsploraClient(url: "https://mutinynet.com/api")
//         let fullScanRequest = wallet.fullScanRequest()
//         let update = try esploraClient.fullScan(
//             request: fullScanRequest,
//             stopGap: UInt64(150), // should we default value this for folks?
//             parallelRequests: UInt64(5) // should we default value this for folks?
//         )
//         let _ = try wallet.applyUpdate(update: update)
//         let isChanged = try wallet.commit()
//         // TODO: Do i need to do this next step of setting wallet to wallet again?
//         // prob not
//         self.wallet = wallet
//     }
    
    func fullScan() async throws {
         guard let wallet = self.wallet else { throw WalletError.walletNotFound }
         let esploraClient = EsploraClient(url: "https://mutinynet.com/api")
         let fullScanRequest = wallet.fullScanRequest()
         let update = try esploraClient.fullScan(
             request: fullScanRequest,
             stopGap: UInt64(150), // should we default value this for folks?
             parallelRequests: UInt64(5) // should we default value this for folks?
         )
         let _ = try wallet.applyUpdate(update: update)
         let isChanged = try wallet.commit()
         // TODO: Do i need to do this next step of setting wallet to wallet again?
         // prob not
         self.wallet = wallet
     }
    
    func calculateFee(tx: Transaction) throws -> UInt64 {
        guard let wallet = self.wallet else {
            throw WalletError.walletNotFound
        }
        let fee = try wallet.calculateFee(tx: tx)
        return fee
    }
    
    func calculateFeeRate(tx: Transaction) throws -> Float {
        guard let wallet = self.wallet else {
            throw WalletError.walletNotFound
        }
        let feeRate = try wallet.calculateFeeRate(tx: tx)
        return feeRate.asSatPerVb()
    }
    
    func sentAndReceived(tx: Transaction) throws -> SentAndReceivedValues {
        guard let wallet = self.wallet else {
            throw WalletError.walletNotFound
        }
        let values = wallet.sentAndReceived(tx: tx)
        return values
    }

}

struct BDKClient {
    let loadWallet: () throws -> Void
    let deleteWallet: () throws -> Void
    let createWallet: (String?) throws -> Void
    let getBalance: () throws -> Balance
    let transactions: () throws -> [Transaction] //let getTransactions: () throws -> [TransactionDetails]
    let sync: () async throws -> Void
    let fullScan: () async throws -> Void
    let getAddress: () throws -> String
    let send: (String, UInt64, Float?) throws -> Void
    let calculateFee: (Transaction) throws -> UInt64
    let calculateFeeRate: (Transaction) throws -> Float
    let sentAndReceived: (Transaction) throws -> SentAndReceivedValues
//    let buildTransaction: (String, UInt64, Float?) throws -> TxBuilderResult
    let getBackupInfo: () throws -> BackupInfo
}

extension BDKClient {
    static let live = Self(
        loadWallet: { try BDKService.shared.loadWalletFromBackup() },
        deleteWallet: { try BDKService.shared.deleteWallet() },
        createWallet: { words in try BDKService.shared.createWallet(words: words) },
        getBalance: { try BDKService.shared.getBalance() },
        transactions: { try BDKService.shared.transactions() },//getTransactions: { try BDKService.shared.getTransactions() },
        sync: { try await BDKService.shared.sync() },
        fullScan: { try await BDKService.shared.fullScan() },
        getAddress: { try BDKService.shared.getAddress() },
        send: { (address, amount, feeRate) in
            Task {try await BDKService.shared.send(address: address, amount: amount, feeRate: feeRate)}//try BDKService.shared.send(address: address, amount: amount, feeRate: feeRate)
        },
        calculateFee: { tx in try BDKService.shared.calculateFee(tx: tx)},
        calculateFeeRate: { tx in try BDKService.shared.calculateFeeRate(tx: tx)},
        sentAndReceived: { tx in try BDKService.shared.sentAndReceived(tx: tx)},
//        send: {
//            try await BDKService.shared.send(
//                address: address, // hardcoded to send back to mutiny faucet
//                amount: amount,
//                feeRate: feeRate
//            )
//        },
//        buildTransaction: { (address, amount, feeRate) in
//            try BDKService.shared.buildTransaction(
//                address: address,
//                amount: amount,
//                feeRate: feeRate
//            )
//        },
        getBackupInfo: { try BDKService.shared.getBackupInfo() }
    )
}

#if DEBUG
    extension BDKClient {
        static let mock = Self(
            loadWallet: {},
            deleteWallet: {},
            createWallet: { _ in },
            getBalance: { mockBalance },
//            getTransactions: { mockTransactionDetails },
            transactions: {
                let mockData: [UInt8] = [0x01, 0x02, 0x03]
                let mockTransaction = try Transaction(transactionBytes: mockData)
                return [mockTransaction]
            },
            sync: {},
            fullScan: {},
            getAddress: { "tb1pd8jmenqpe7rz2mavfdx7uc8pj7vskxv4rl6avxlqsw2u8u7d4gfs97durt" },
            send: { _, _, _ in },
            calculateFee: { _ in return UInt64(615) },
            calculateFeeRate: { _ in return Float(6.15) },
            sentAndReceived: { _ in
                return SentAndReceivedValues(sent: UInt64(615), received: UInt64(21))
            },
//            buildTransaction: { _, _, _ in
//                let pb64 = """
//                    cHNidP8BAIkBAAAAAeaWcxp4/+xSRJ2rhkpUJ+jQclqocoyuJ/ulSZEgEkaoAQAAAAD+////Ak/cDgAAAAAAIlEgqxShDO8ifAouGyRHTFxWnTjpY69Cssr3IoNQvMYOKG/OVgAAAAAAACJRIGnlvMwBz4Ylb6xLTe5g4ZeZCxmVH/XWG+CDlcPzzaoT8qoGAAABAStAQg8AAAAAACJRIFGGvSoLWt3hRAIwYa8KEyawiFTXoOCVWFxYtSofZuAsIRZ2b8YiEpzexWYGt8B5EqLM8BE4qxJY3pkiGw/8zOZGYxkAvh7sj1YAAIABAACAAAAAgAAAAAAEAAAAARcgdm/GIhKc3sVmBrfAeRKizPAROKsSWN6ZIhsP/MzmRmMAAQUge7cvJMsJmR56NzObGOGkm8vNqaAIJdnBXLZD2PvrinIhB3u3LyTLCZkeejczmxjhpJvLzamgCCXZwVy2Q9j764pyGQC+HuyPVgAAgAEAAIAAAACAAQAAAAYAAAAAAQUgtIFPrI2EW/+PJiAmYdmux88p0KgeAxDFLMoeQoS66hIhB7SBT6yNhFv/jyYgJmHZrsfPKdCoHgMQxSzKHkKEuuoSGQC+HuyPVgAAgAEAAIAAAACAAAAAAAIAAAAA
//                    """
//                return try! TxBuilderResult(
//                    psbt: .init(psbtBase64: pb64),
//                    transactionDetails: mockTransactionDetail
//                )
//            },
            getBackupInfo: {
                BackupInfo(
                    mnemonic: "mnemonic",
                    descriptor: "descriptor",
                    changeDescriptor: "changeDescriptor"
                )
            }
        )
//        static let mockZero = Self(
//            loadWallet: {},
//            deleteWallet: {},
//            createWallet: { _ in },
//            getBalance: { mockBalanceZero },
//            getTransactions: { mockTransactionDetailsZero },
//            sync: {},
//            getAddress: { "tb1pd8jmenqpe7rz2mavfdx7uc8pj7vskxv4rl6avxlqsw2u8u7d4gfs97durt" },
//            send: { _, _, _ in },
//            buildTransaction: { _, _, _ in
//                return try! TxBuilderResult(
//                    psbt: .init(psbtBase64: "psbtBase64"),
//                    transactionDetails: mockTransactionDetail
//                )
//            },
//            getBackupInfo: {
//                BackupInfo(
//                    mnemonic: "mnemonic",
//                    descriptor: "descriptor",
//                    changeDescriptor: "changeDescriptor"
//                )
//            }
//        )
    }
#endif
