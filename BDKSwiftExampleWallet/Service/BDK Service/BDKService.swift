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
    var network: Network
    private var wallet: Wallet?
    private let keyService: KeyClient
    private let esploraClient: EsploraClient
    private var needsFullScan: Bool = false
    private var dbService: SqliteStore?

    init(
        keyService: KeyClient = .live
    ) {
        let storedNetworkString = try! keyService.getNetwork() ?? Network.testnet.description
        let storedEsploraURL =
            try! keyService.getEsploraURL()
            ?? Constants.Config.EsploraServerURLNetwork.Testnet.mempoolspace

        self.network = Network(stringValue: storedNetworkString) ?? .testnet
        self.keyService = keyService
        self.esploraClient = EsploraClient(url: storedEsploraURL)
    }

    func getAddress() throws -> String {
        guard let wallet = self.wallet else {
            throw WalletError.walletNotFound
        }
        let addressInfo = wallet.revealNextAddress(keychain: .external)
        guard let db = self.dbService else { throw WalletError.dbNotFound }
        if let changeSet = wallet.takeStaged() {
            try db.write(changeSet: changeSet)
        }
        return addressInfo.address.description
    }

    func getBalance() throws -> Balance {
        guard let wallet = self.wallet else { throw WalletError.walletNotFound }
        let balance = wallet.balance()
        return balance
    }

    func transactions() throws -> [CanonicalTx] {
        guard let wallet = self.wallet else {
            throw WalletError.walletNotFound
        }
        let transactions = wallet.transactions()
        return transactions
    }

    func createWallet(words: String?) throws {

        let baseUrl =
            try keyService.getEsploraURL()
            ?? Constants.Config.EsploraServerURLNetwork.Testnet.mempoolspace

        var words12: String
        if let words = words, !words.isEmpty {
            words12 = words
            needsFullScan = true
        } else {
            let mnemonic = Mnemonic(wordCount: WordCount.words12)
            words12 = mnemonic.description
            needsFullScan = false
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
            mnemonic: mnemonic.description,
            descriptor: descriptor.description,
            changeDescriptor: changeDescriptor.toStringWithSecret()
        )

        try keyService.saveBackupInfo(backupInfo)
        try keyService.saveNetwork(self.network.description)
        try keyService.saveEsploraURL(baseUrl)

        let documentsDirectoryURL = URL.documentsDirectory
        let walletDataDirectoryURL = documentsDirectoryURL.appendingPathComponent("wallet_data")
        let persistenceBackendPath = walletDataDirectoryURL.appendingPathComponent("wallet.sqlite")
            .path
        let sqliteStore = try SqliteStore(path: persistenceBackendPath)
        self.dbService = sqliteStore
        let changeSet = try sqliteStore.read()
        let wallet = try Wallet.newOrLoad(
            descriptor: descriptor,
            changeDescriptor: changeDescriptor,
            changeSet: changeSet,
            network: network
        )
        self.wallet = wallet
    }

    private func loadWallet(descriptor: Descriptor, changeDescriptor: Descriptor) throws {
        let documentsDirectoryURL = URL.documentsDirectory
        let walletDataDirectoryURL = documentsDirectoryURL.appendingPathComponent("wallet_data")
        let persistenceBackendPath = walletDataDirectoryURL.appendingPathComponent("wallet.sqlite")
            .path
        let sqliteStore = try SqliteStore(path: persistenceBackendPath)
        self.dbService = sqliteStore
        let changeSet = try sqliteStore.read()
        let wallet = try Wallet.newOrLoad(
            descriptor: descriptor,
            changeDescriptor: changeDescriptor,
            changeSet: changeSet,
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
        needsFullScan = true
    }

    func getBackupInfo() throws -> BackupInfo {
        let backupInfo = try keyService.getBackupInfo()
        return backupInfo
    }

    func send(
        address: String,
        amount: UInt64,
        feeRate: UInt64
    ) async throws {
        let psbt = try buildTransaction(
            address: address,
            amount: amount,
            feeRate: feeRate
        )
        try signAndBroadcast(psbt: psbt)
    }

    func buildTransaction(address: String, amount: UInt64, feeRate: UInt64) throws
        -> Psbt
    {
        guard let wallet = self.wallet else { throw WalletError.walletNotFound }
        let script = try Address(address: address, network: self.network)
            .scriptPubkey()
        let txBuilder = try TxBuilder()
            .addRecipient(
                script: script,
                amount: Amount.fromSat(fromSat: amount)
            )
            .feeRate(feeRate: FeeRate.fromSatPerVb(satPerVb: feeRate))
            .finish(wallet: wallet)
        return txBuilder
    }

    private func signAndBroadcast(psbt: Psbt) throws {
        guard let wallet = self.wallet else { throw WalletError.walletNotFound }
        let _ = try wallet.sign(psbt: psbt)
        let transaction = try psbt.extractTx()
        let client = self.esploraClient
        try client.broadcast(transaction: transaction)
    }

    func syncWithInspector(inspector: SyncScriptInspector) async throws {
        guard let wallet = self.wallet else { throw WalletError.walletNotFound }
        let esploraClient = self.esploraClient
        let syncRequest = try wallet.startSyncWithRevealedSpks()
            .inspectSpks(inspector: inspector)
        let update = try esploraClient.sync(
            syncRequest: syncRequest,
            parallelRequests: UInt64(5)
        )
        let _ = try wallet.applyUpdate(update: update)
        guard let db = self.dbService else { throw WalletError.dbNotFound }
        if let changeSet = wallet.takeStaged() {
            try db.write(changeSet: changeSet)
        }
    }

    func fullScanWithInspector(inspector: FullScanScriptInspector) async throws {
        guard let wallet = self.wallet else { throw WalletError.walletNotFound }
        let esploraClient = esploraClient
        let fullScanRequest = try wallet.startFullScan()
            .inspectSpksForAllKeychains(inspector: inspector)
        let update = try esploraClient.fullScan(
            fullScanRequest: fullScanRequest,
            stopGap: UInt64(150),  // should we default value this for folks?
            parallelRequests: UInt64(5)  // should we default value this for folks?
        )
        let _ = try wallet.applyUpdate(update: update)
        guard let db = self.dbService else { throw WalletError.dbNotFound }
        if let changeSet = wallet.takeStaged() {
            try db.write(changeSet: changeSet)
        }
    }

    func calculateFee(tx: Transaction) throws -> Amount {
        guard let wallet = self.wallet else {
            throw WalletError.walletNotFound
        }
        let fee = try wallet.calculateFee(tx: tx)
        return fee
    }

    func calculateFeeRate(tx: Transaction) throws -> UInt64 {
        guard let wallet = self.wallet else {
            throw WalletError.walletNotFound
        }
        let feeRate = try wallet.calculateFeeRate(tx: tx)
        return feeRate.toSatPerVbCeil()
    }

    func sentAndReceived(tx: Transaction) throws -> SentAndReceivedValues {
        guard let wallet = self.wallet else {
            throw WalletError.walletNotFound
        }
        let values = wallet.sentAndReceived(tx: tx)
        return values
    }

}

extension BDKService {
    func needsFullScanOfWallet() -> Bool {
        return needsFullScan
    }

    func setNeedsFullScan(_ value: Bool) {
        needsFullScan = value
    }
}

struct BDKClient {
    let loadWallet: () throws -> Void
    let deleteWallet: () throws -> Void
    let createWallet: (String?) throws -> Void
    let getBalance: () throws -> Balance
    let transactions: () throws -> [CanonicalTx]
    let syncWithInspector: (SyncScriptInspector) async throws -> Void
    let fullScanWithInspector: (FullScanScriptInspector) async throws -> Void
    let getAddress: () throws -> String
    let send: (String, UInt64, UInt64) throws -> Void
    let calculateFee: (Transaction) throws -> Amount
    let calculateFeeRate: (Transaction) throws -> UInt64
    let sentAndReceived: (Transaction) throws -> SentAndReceivedValues
    let buildTransaction: (String, UInt64, UInt64) throws -> Psbt
    let getBackupInfo: () throws -> BackupInfo
    let needsFullScan: () -> Bool
    let setNeedsFullScan: (Bool) -> Void
}

extension BDKClient {
    static let live = Self(
        loadWallet: { try BDKService.shared.loadWalletFromBackup() },
        deleteWallet: { try BDKService.shared.deleteWallet() },
        createWallet: { words in try BDKService.shared.createWallet(words: words) },
        getBalance: { try BDKService.shared.getBalance() },
        transactions: { try BDKService.shared.transactions() },
        syncWithInspector: { inspector in
            try await BDKService.shared.syncWithInspector(inspector: inspector)
        },
        fullScanWithInspector: { inspector in
            try await BDKService.shared.fullScanWithInspector(inspector: inspector)
        },
        getAddress: { try BDKService.shared.getAddress() },
        send: { (address, amount, feeRate) in
            Task {
                try await BDKService.shared.send(address: address, amount: amount, feeRate: feeRate)
            }
        },
        calculateFee: { tx in try BDKService.shared.calculateFee(tx: tx) },
        calculateFeeRate: { tx in try BDKService.shared.calculateFeeRate(tx: tx) },
        sentAndReceived: { tx in try BDKService.shared.sentAndReceived(tx: tx) },
        buildTransaction: { (address, amount, feeRate) in
            try BDKService.shared.buildTransaction(
                address: address,
                amount: amount,
                feeRate: feeRate
            )
        },
        getBackupInfo: { try BDKService.shared.getBackupInfo() },
        needsFullScan: { BDKService.shared.needsFullScanOfWallet() },
        setNeedsFullScan: { value in BDKService.shared.setNeedsFullScan(value) }
    )
}

#if DEBUG
    extension BDKClient {
        static let mock = Self(
            loadWallet: {},
            deleteWallet: {},
            createWallet: { _ in },
            getBalance: { .mock },
            transactions: {
                return [
                    .mock
                ]
            },
            syncWithInspector: { _ in },
            fullScanWithInspector: { _ in },
            getAddress: { "tb1pd8jmenqpe7rz2mavfdx7uc8pj7vskxv4rl6avxlqsw2u8u7d4gfs97durt" },
            send: { _, _, _ in },
            calculateFee: { _ in Amount.fromSat(fromSat: UInt64(615)) },
            calculateFeeRate: { _ in return UInt64(6.15) },
            sentAndReceived: { _ in
                return SentAndReceivedValues(
                    sent: Amount.fromSat(fromSat: UInt64(20000)),
                    received: Amount.fromSat(fromSat: UInt64(210))
                )
            },
            buildTransaction: { _, _, _ in
                let pb64 = """
                    cHNidP8BAIkBAAAAAeaWcxp4/+xSRJ2rhkpUJ+jQclqocoyuJ/ulSZEgEkaoAQAAAAD+////Ak/cDgAAAAAAIlEgqxShDO8ifAouGyRHTFxWnTjpY69Cssr3IoNQvMYOKG/OVgAAAAAAACJRIGnlvMwBz4Ylb6xLTe5g4ZeZCxmVH/XWG+CDlcPzzaoT8qoGAAABAStAQg8AAAAAACJRIFGGvSoLWt3hRAIwYa8KEyawiFTXoOCVWFxYtSofZuAsIRZ2b8YiEpzexWYGt8B5EqLM8BE4qxJY3pkiGw/8zOZGYxkAvh7sj1YAAIABAACAAAAAgAAAAAAEAAAAARcgdm/GIhKc3sVmBrfAeRKizPAROKsSWN6ZIhsP/MzmRmMAAQUge7cvJMsJmR56NzObGOGkm8vNqaAIJdnBXLZD2PvrinIhB3u3LyTLCZkeejczmxjhpJvLzamgCCXZwVy2Q9j764pyGQC+HuyPVgAAgAEAAIAAAACAAQAAAAYAAAAAAQUgtIFPrI2EW/+PJiAmYdmux88p0KgeAxDFLMoeQoS66hIhB7SBT6yNhFv/jyYgJmHZrsfPKdCoHgMQxSzKHkKEuuoSGQC+HuyPVgAAgAEAAIAAAACAAAAAAAIAAAAA
                    """
                return try! Psbt(psbtBase64: pb64)
            },
            getBackupInfo: {
                BackupInfo(
                    mnemonic:
                        "excite mesh empower noble virus main flee cake gorilla weapon maid radio",
                    descriptor:
                        "tr(tprv8ZgxMBicQKsPdXGCpRXi6PRsH2BaTpP2Aw4K7J5BLVEWHfXYfLZKsPh43VQncqSJucGj6KvzLTNayDcRJEKMfEqLGN1Pi3jjnM7mwRxGQ1s/86\'/1\'/0\'/0/*)#q4yvkz4r",
                    changeDescriptor:
                        "tr(tprv8ZgxMBicQKsPdXGCpRXi6PRsH2BaTpP2Aw4K7J5BLVEWHfXYfLZKsPh43VQncqSJucGj6KvzLTNayDcRJEKMfEqLGN1Pi3jjnM7mwRxGQ1s/86\'/1\'/0\'/1/*)#3ppdth9m"
                )
            },
            needsFullScan: { true },
            setNeedsFullScan: { _ in }
        )
    }
#endif
