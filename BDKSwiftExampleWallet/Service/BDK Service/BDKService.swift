//
//  BDKService.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 5/23/23.
//

import BitcoinDevKit
import Foundation

enum BlockchainClientType: String, CaseIterable {
    case esplora = "esplora"
    case kyoto = "kyoto"
    case electrum = "electrum"  // future
}

struct BlockchainClient {
    let sync: @Sendable (SyncRequest, UInt64) async throws -> Update
    let fullScan: @Sendable (FullScanRequest, UInt64, UInt64) async throws -> Update
    let broadcast: @Sendable (Transaction) throws -> Void
    let getUrl: @Sendable () -> String
    let getType: @Sendable () -> BlockchainClientType
    let supportsFullScan: @Sendable () -> Bool = { true }
}

extension BlockchainClient {
    static func esplora(url: String) -> Self {
        let client = EsploraClient(url: url)
        return Self(
            sync: { request, parallel in
                try client.sync(request: request, parallelRequests: parallel)
            },
            fullScan: { request, stopGap, parallel in
                try client.fullScan(request: request, stopGap: stopGap, parallelRequests: parallel)
            },
            broadcast: { tx in
                try client.broadcast(transaction: tx)
            },
            getUrl: { url },
            getType: { .esplora }
        )
    }

    static func kyoto(peer: String) -> Self {
        var cbfComponents: (client: CbfClient, node: CbfNode)? = nil

        func getOrCreateComponents() throws -> (client: CbfClient, node: CbfNode) {
            if let existing = cbfComponents {
                return existing
            }

            guard let wallet = BDKService.shared.wallet else {
                throw WalletError.walletNotFound
            }

            try FileManager.default.ensureDirectoryExists(at: Constants.Config.Kyoto.dbDirectoryURL)

            let components = CbfClient.createComponents(wallet: wallet)
            cbfComponents = components
            return components
        }

        return Self(
            sync: { request, _ in
                let components = try getOrCreateComponents()
                return try await components.client.update()
            },
            fullScan: { request, stopGap, _ in
                let components = try getOrCreateComponents()
                return try await components.client.update()
            },
            broadcast: { tx in
                let components = try getOrCreateComponents()
                try components.client.broadcast(transaction: tx)
            },
            getUrl: { peer },
            getType: { .kyoto }
        )
    }
}

private class BDKService {
    static let shared: BDKService = BDKService()

    private var balance: Balance?
    private var persister: Persister?
    private var blockchainClient: BlockchainClient
    internal private(set) var clientType: BlockchainClientType
    private let keyClient: KeyClient
    private var needsFullScan: Bool = false
    private(set) var network: Network
    private var blockchainURL: String
    internal private(set) var wallet: Wallet?

    init(keyClient: KeyClient = .live) {
        self.keyClient = keyClient
        let storedNetworkString = try? keyClient.getNetwork() ?? Network.signet.description
        self.network = Network(stringValue: storedNetworkString ?? "") ?? .signet

        let storedClientType = try? keyClient.getClientType()
        self.clientType = storedClientType ?? .esplora

        // Ensure Kyoto always uses Signet
        if self.clientType == .kyoto && self.network != .signet {
            self.network = .signet
            try? keyClient.saveNetwork(Network.signet.description)
        }

        if self.clientType == .kyoto {
            self.blockchainURL = Constants.Config.Kyoto.getDefaultPeer(for: self.network)
        } else {
            self.blockchainURL = (try? keyClient.getEsploraURL()) ?? ""
            if self.blockchainURL.isEmpty {
                self.blockchainURL = self.network.url
            }
        }
        self.blockchainClient = BlockchainClient.esplora(url: self.blockchainURL)
        updateBlockchainClient()
    }

    func updateNetwork(_ newNetwork: Network) {
        if newNetwork != self.network {
            if (try? keyClient.getBackupInfo()) != nil {
                return
            }

            // If Kyoto is selected force network to Signet and persist correction
            if self.clientType == .kyoto && newNetwork != .signet {
                self.network = .signet
                try? keyClient.saveNetwork(Network.signet.description)
                self.blockchainURL = Constants.Config.Kyoto.getDefaultPeer(for: .signet)
                updateBlockchainClient()
                return
            }

            self.network = newNetwork
            try? keyClient.saveNetwork(newNetwork.description)

            // Only update URL for Esplora clients, Kyoto uses peer addresses
            if self.clientType == .esplora {
                let newURL = newNetwork.url
                updateBlockchainURL(newURL)
            } else if self.clientType == .kyoto {
                // For Kyoto update to the correct peer for the new network
                let newPeer = Constants.Config.Kyoto.getDefaultPeer(for: newNetwork)
                self.blockchainURL = newPeer
                updateBlockchainClient()
            }
        }
    }

    func updateBlockchainURL(_ newURL: String) {
        if newURL != self.blockchainURL {
            self.blockchainURL = newURL
            try? keyClient.saveEsploraURL(newURL)
            updateBlockchainClient()
        }
    }

    internal func updateBlockchainClient() {
        do {
            switch clientType {
            case .esplora:
                self.blockchainClient = .esplora(url: self.blockchainURL)
            case .kyoto:
                if self.network != .signet {
                    self.clientType = .esplora
                    self.blockchainClient = .esplora(url: self.blockchainURL)
                } else {
                    let peer =
                        self.blockchainURL.isEmpty
                        ? Constants.Config.Kyoto.getDefaultPeer(for: self.network)
                        : self.blockchainURL
                    self.blockchainClient = .kyoto(peer: peer)
                }
            case .electrum:
                throw WalletError.backendNotImplemented
            }
        } catch {
            self.clientType = .esplora
            self.blockchainClient = .esplora(url: self.blockchainURL)
        }
    }

    private func getCurrentAddressType() -> AddressType {
        let storedAddressTypeString =
            try? keyClient.getAddressType() ?? AddressType.bip86.description
        return AddressType(stringValue: storedAddressTypeString ?? "") ?? .bip86
    }

    private func createDescriptors(
        for addressType: AddressType,
        secretKey: DescriptorSecretKey,
        network: Network
    ) -> (descriptor: Descriptor, changeDescriptor: Descriptor) {
        switch addressType {
        case .bip86:
            let descriptor = Descriptor.newBip86(
                secretKey: secretKey,
                keychainKind: .external,
                network: network
            )
            let changeDescriptor = Descriptor.newBip86(
                secretKey: secretKey,
                keychainKind: .internal,
                network: network
            )
            return (descriptor, changeDescriptor)
        case .bip84:
            let descriptor = Descriptor.newBip84(
                secretKey: secretKey,
                keychainKind: .external,
                network: network
            )
            let changeDescriptor = Descriptor.newBip84(
                secretKey: secretKey,
                keychainKind: .internal,
                network: network
            )
            return (descriptor, changeDescriptor)
        }
    }

    private func createPublicDescriptors(
        for addressType: AddressType,
        publicKey: DescriptorPublicKey,
        fingerprint: String,
        network: Network
    ) -> (descriptor: Descriptor, changeDescriptor: Descriptor) {
        switch addressType {
        case .bip86:
            let descriptor = Descriptor.newBip86Public(
                publicKey: publicKey,
                fingerprint: fingerprint,
                keychainKind: .external,
                network: network
            )
            let changeDescriptor = Descriptor.newBip86Public(
                publicKey: publicKey,
                fingerprint: fingerprint,
                keychainKind: .internal,
                network: network
            )
            return (descriptor, changeDescriptor)
        case .bip84:
            let descriptor = Descriptor.newBip84Public(
                publicKey: publicKey,
                fingerprint: fingerprint,
                keychainKind: .external,
                network: network
            )
            let changeDescriptor = Descriptor.newBip84Public(
                publicKey: publicKey,
                fingerprint: fingerprint,
                keychainKind: .internal,
                network: network
            )
            return (descriptor, changeDescriptor)
        }
    }

    func getAddress() throws -> String {
        guard let wallet = self.wallet else {
            throw WalletError.walletNotFound
        }
        guard let persister = self.persister else {
            throw WalletError.dbNotFound
        }
        let addressInfo = wallet.revealNextAddress(keychain: .external)
        let _ = try wallet.persist(persister: persister)
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
        let sortedTransactions = transactions.sorted { (tx1, tx2) in
            return tx1.chainPosition.isBefore(tx2.chainPosition)
        }
        return sortedTransactions
    }

    func listUnspent() throws -> [LocalOutput] {
        guard let wallet = self.wallet else {
            throw WalletError.walletNotFound
        }
        let localOutputs = wallet.listUnspent()
        return localOutputs
    }

    func createWallet(words: String?) throws {
        self.persister = try Persister.createConnection()
        guard let persister = persister else {
            throw WalletError.dbNotFound
        }

        let baseUrl: String
        if self.clientType == .kyoto {
            baseUrl = Constants.Config.Kyoto.getDefaultPeer(for: network)
        } else {
            let savedURL = try? keyClient.getEsploraURL()
            baseUrl = savedURL ?? network.url
        }

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
        let currentAddressType = getCurrentAddressType()
        let descriptors = createDescriptors(
            for: currentAddressType,
            secretKey: secretKey,
            network: network
        )
        let descriptor = descriptors.descriptor
        let changeDescriptor = descriptors.changeDescriptor
        let backupInfo = BackupInfo(
            mnemonic: mnemonic.description,
            descriptor: descriptor.toStringWithSecret(),
            changeDescriptor: changeDescriptor.toStringWithSecret()
        )

        try keyClient.saveBackupInfo(backupInfo)
        try keyClient.saveNetwork(self.network.description)
        try keyClient.saveEsploraURL(baseUrl)
        self.blockchainURL = baseUrl
        updateBlockchainClient()

        let wallet = try Wallet(
            descriptor: descriptor,
            changeDescriptor: changeDescriptor,
            network: network,
            persister: persister
        )
        self.wallet = wallet
    }

    func createWallet(descriptor: String?) throws {
        self.persister = try Persister.createConnection()
        guard let persister = persister else {
            throw WalletError.dbNotFound
        }

        let savedURL = try? keyClient.getEsploraURL()
        let baseUrl = savedURL ?? network.url

        guard let descriptorString = descriptor, !descriptorString.isEmpty else {
            throw WalletError.walletNotFound
        }

        let descriptorStrings = descriptorString.components(separatedBy: "\n")
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
                throw WalletError.walletNotFound
            }
            descriptor = singleDescriptors[0]
            changeDescriptor = singleDescriptors[1]
        } else if descriptorStrings.count == 2 {
            descriptor = try Descriptor(descriptor: descriptorStrings[0], network: network)
            changeDescriptor = try Descriptor(descriptor: descriptorStrings[1], network: network)
        } else {
            throw WalletError.walletNotFound
        }

        let backupInfo = BackupInfo(
            mnemonic: "",
            descriptor: descriptor.toStringWithSecret(),
            changeDescriptor: changeDescriptor.toStringWithSecret()
        )

        try keyClient.saveBackupInfo(backupInfo)
        try keyClient.saveNetwork(self.network.description)
        try keyClient.saveEsploraURL(baseUrl)

        let wallet = try Wallet(
            descriptor: descriptor,
            changeDescriptor: changeDescriptor,
            network: network,
            persister: persister
        )
        self.wallet = wallet
    }

    func createWallet(xpub: String?) throws {
        self.persister = try Persister.createConnection()
        guard let persister = persister else {
            throw WalletError.dbNotFound
        }

        let baseUrl: String
        if self.clientType == .kyoto {
            baseUrl = Constants.Config.Kyoto.getDefaultPeer(for: network)
        } else {
            let savedURL = try? keyClient.getEsploraURL()
            baseUrl = savedURL ?? network.url
        }

        guard let xpubString = xpub, !xpubString.isEmpty else {
            throw WalletError.walletNotFound
        }

        let descriptorPublicKey = try DescriptorPublicKey.fromString(publicKey: xpubString)
        let fingerprint = descriptorPublicKey.masterFingerprint()
        let currentAddressType = getCurrentAddressType()
        let descriptors = createPublicDescriptors(
            for: currentAddressType,
            publicKey: descriptorPublicKey,
            fingerprint: fingerprint,
            network: network
        )
        let descriptor = descriptors.descriptor
        let changeDescriptor = descriptors.changeDescriptor

        let backupInfo = BackupInfo(
            mnemonic: "",
            descriptor: descriptor.toStringWithSecret(),
            changeDescriptor: changeDescriptor.toStringWithSecret()
        )

        try keyClient.saveBackupInfo(backupInfo)
        try keyClient.saveNetwork(self.network.description)
        try keyClient.saveEsploraURL(baseUrl)
        self.blockchainURL = baseUrl
        updateBlockchainClient()

        let wallet = try Wallet(
            descriptor: descriptor,
            changeDescriptor: changeDescriptor,
            network: network,
            persister: persister
        )
        self.wallet = wallet
    }

    private func loadWallet(
        descriptor: Descriptor,
        changeDescriptor:
            Descriptor
    ) throws {
        // If database doesn't exist, create it from the descriptors
        if !FileManager.default.fileExists(
            atPath:
                URL.persistenceBackendPath
        ) {
            let persister = try Persister.createConnection()
            self.persister = persister
            let wallet = try Wallet(
                descriptor: descriptor,
                changeDescriptor: changeDescriptor,
                network: self.network,
                persister: persister
            )
            self.wallet = wallet
        } else {
            // Database exists, try to load the wallet
            do {
                let persister = try Persister.loadConnection()
                self.persister = persister
                let wallet = try Wallet.load(
                    descriptor: descriptor,
                    changeDescriptor: changeDescriptor,
                    persister: persister
                )
                self.wallet = wallet
            } catch is LoadWithPersistError {
                // Database is corrupted or incompatible, delete and recreate
                try Persister.deleteConnection()

                let persister = try Persister.createConnection()
                self.persister = persister
                let wallet = try Wallet(
                    descriptor: descriptor,
                    changeDescriptor: changeDescriptor,
                    network: self.network,
                    persister: persister
                )
                self.wallet = wallet
            }
        }
    }

    func loadWalletFromBackup() throws {
        let backupInfo = try keyClient.getBackupInfo()
        let descriptor = try Descriptor(descriptor: backupInfo.descriptor, network: self.network)
        let changeDescriptor = try Descriptor(
            descriptor: backupInfo.changeDescriptor,
            network: self.network
        )
        try self.loadWallet(descriptor: descriptor, changeDescriptor: changeDescriptor)
    }

    func deleteWallet() throws {
        let savedURL = try? keyClient.getEsploraURL()
        let savedNetwork = try? keyClient.getNetwork()

        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        try self.keyClient.deleteBackupInfo()
        try Persister.deleteConnection()
        if let savedURL = savedURL {
            try keyClient.saveEsploraURL(savedURL)
        }
        if let savedNetwork = savedNetwork {
            try keyClient.saveNetwork(savedNetwork)
        }

        needsFullScan = true
    }

    func getBackupInfo() throws -> BackupInfo {
        let backupInfo = try keyClient.getBackupInfo()
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
        try await signAndBroadcast(psbt: psbt)
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
                amount: Amount.fromSat(satoshi: amount)
            )
            .feeRate(feeRate: FeeRate.fromSatPerVb(satVb: feeRate))
            .finish(wallet: wallet)
        return txBuilder
    }

    private func signAndBroadcast(psbt: Psbt) async throws {
        guard let wallet = self.wallet else { throw WalletError.walletNotFound }
        let isSigned = try wallet.sign(psbt: psbt)
        if isSigned {
            let transaction = try psbt.extractTx()
            try self.blockchainClient.broadcast(transaction)
        } else {
            throw WalletError.notSigned
        }
    }

    func syncWithInspector(inspector: SyncScriptInspector) async throws {
        guard let wallet = self.wallet else { throw WalletError.walletNotFound }
        let syncRequest = try wallet.startSyncWithRevealedSpks()
            .inspectSpks(inspector: inspector)
            .build()
        let update = try await self.blockchainClient.sync(
            syncRequest,
            UInt64(5)
        )
        let _ = try wallet.applyUpdate(update: update)
        guard let persister = self.persister else {
            throw WalletError.dbNotFound
        }
        let _ = try wallet.persist(persister: persister)
    }

    func fullScanWithInspector(inspector: FullScanScriptInspector) async throws {
        guard let wallet = self.wallet else { throw WalletError.walletNotFound }
        guard self.blockchainClient.supportsFullScan() else {
            throw WalletError.fullScanUnsupported
        }
        let fullScanRequest = try wallet.startFullScan()
            .inspectSpksForAllKeychains(inspector: inspector)
            .build()
        let update = try await self.blockchainClient.fullScan(
            fullScanRequest,
            // using https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki#address-gap-limit
            UInt64(20),
            // using https://github.com/bitcoindevkit/bdk/blob/master/example-crates/example_wallet_esplora_blocking/src/main.rs
            UInt64(5)
        )
        let _ = try wallet.applyUpdate(update: update)
        guard let persister = self.persister else {
            throw WalletError.dbNotFound
        }
        let _ = try wallet.persist(persister: persister)
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

    func txDetails(txid: Txid) throws -> TxDetails? {
        guard let wallet = self.wallet else {
            throw WalletError.walletNotFound
        }
        let txDetails = wallet.txDetails(txid: txid)
        return txDetails
    }
}

extension BDKService {
    func needsFullScanOfWallet() -> Bool {
        return needsFullScan
    }

    func setNeedsFullScan(_ value: Bool) {
        needsFullScan = value
    }

    func getAddressType() -> AddressType {
        return getCurrentAddressType()
    }

    func updateAddressType(_ newAddressType: AddressType) {
        let currentType = getCurrentAddressType()
        try? keyClient.saveAddressType(newAddressType.description)

        // If address type changed, we need a full scan to find transactions with new derivation paths
        if currentType != newAddressType {
            needsFullScan = true
        }
    }

    func updateClientType(_ newType: BlockchainClientType) {
        self.clientType = newType
        try? keyClient.saveClientType(newType)

        // Update URL to match the new client type
        if newType == .kyoto {
            // Force Signet network for Kyoto and persist the corrected network
            if self.network != .signet {
                self.network = .signet
                try? keyClient.saveNetwork(Network.signet.description)
            }
            self.blockchainURL = Constants.Config.Kyoto.getDefaultPeer(for: .signet)
        } else if newType == .esplora {
            // Keep existing URL if it's valid for this network, otherwise use default
            let defaultEsploraURL = self.network.url
            if self.blockchainURL.isEmpty || self.blockchainURL.starts(with: "127.0.0.1") {
                self.blockchainURL = defaultEsploraURL
            }
        }

        updateBlockchainClient()
    }

    var esploraURL: String {
        return blockchainURL
    }

    func updateEsploraURL(_ newURL: String) {
        updateBlockchainURL(newURL)
    }
}

struct BDKClient {
    let loadWallet: () throws -> Void
    let deleteWallet: () throws -> Void
    let createWalletFromSeed: (String?) throws -> Void
    let createWalletFromDescriptor: (String?) throws -> Void
    let createWalletFromXPub: (String?) throws -> Void
    let getBalance: () throws -> Balance
    let transactions: () throws -> [CanonicalTx]
    let listUnspent: () throws -> [LocalOutput]
    let syncWithInspector: (SyncScriptInspector) async throws -> Void
    let fullScanWithInspector: (FullScanScriptInspector) async throws -> Void
    let getAddress: () throws -> String
    let send: (String, UInt64, UInt64) throws -> Void
    let calculateFee: (Transaction) throws -> Amount
    let calculateFeeRate: (Transaction) throws -> UInt64
    let sentAndReceived: (Transaction) throws -> SentAndReceivedValues
    let txDetails: (Txid) throws -> TxDetails?
    let buildTransaction: (String, UInt64, UInt64) throws -> Psbt
    let getBackupInfo: () throws -> BackupInfo
    let needsFullScan: () -> Bool
    let setNeedsFullScan: (Bool) -> Void
    let getNetwork: () -> Network
    let getEsploraURL: () -> String
    let updateNetwork: (Network) -> Void
    let updateEsploraURL: (String) -> Void
    let getAddressType: () -> AddressType
    let updateAddressType: (AddressType) -> Void
    let getClientType: () -> BlockchainClientType
    let updateClientType: (BlockchainClientType) -> Void
}

extension BDKClient {
    static let live = Self(
        loadWallet: { try BDKService.shared.loadWalletFromBackup() },
        deleteWallet: { try BDKService.shared.deleteWallet() },
        createWalletFromSeed: { words in try BDKService.shared.createWallet(words: words) },
        createWalletFromDescriptor: { descriptor in
            try BDKService.shared.createWallet(descriptor: descriptor)
        },
        createWalletFromXPub: { xpub in
            try BDKService.shared.createWallet(xpub: xpub)
        },
        getBalance: { try BDKService.shared.getBalance() },
        transactions: { try BDKService.shared.transactions() },
        listUnspent: { try BDKService.shared.listUnspent() },
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
        txDetails: { txid in try BDKService.shared.txDetails(txid: txid) },
        buildTransaction: { (address, amount, feeRate) in
            try BDKService.shared.buildTransaction(
                address: address,
                amount: amount,
                feeRate: feeRate
            )
        },
        getBackupInfo: { try BDKService.shared.getBackupInfo() },
        needsFullScan: { BDKService.shared.needsFullScanOfWallet() },
        setNeedsFullScan: { value in BDKService.shared.setNeedsFullScan(value) },
        getNetwork: {
            BDKService.shared.network
        },
        getEsploraURL: {
            BDKService.shared.esploraURL
        },
        updateNetwork: { newNetwork in
            BDKService.shared.updateNetwork(newNetwork)
        },
        updateEsploraURL: { newURL in
            BDKService.shared.updateEsploraURL(newURL)
        },
        getAddressType: {
            BDKService.shared.getAddressType()
        },
        updateAddressType: { newAddressType in
            BDKService.shared.updateAddressType(newAddressType)
        },
        getClientType: { BDKService.shared.clientType },
        updateClientType: { newType in
            BDKService.shared.updateClientType(newType)
        }
    )
}

#if DEBUG
    extension BDKClient {
        static let mock = Self(
            loadWallet: {},
            deleteWallet: {},
            createWalletFromSeed: { _ in },
            createWalletFromDescriptor: { _ in },
            createWalletFromXPub: { _ in },
            getBalance: { .mock },
            transactions: {
                return [
                    .mock
                ]
            },
            listUnspent: {
                return [
                    .mock
                ]
            },
            syncWithInspector: { _ in },
            fullScanWithInspector: { _ in },
            getAddress: { "tb1pd8jmenqpe7rz2mavfdx7uc8pj7vskxv4rl6avxlqsw2u8u7d4gfs97durt" },
            send: { _, _, _ in },
            calculateFee: { _ in Amount.mock },
            calculateFeeRate: { _ in UInt64(6.15) },
            sentAndReceived: { _ in
                return SentAndReceivedValues(
                    sent: .mock,
                    received: .mock
                )
            },
            txDetails: { _ in .mock },
            buildTransaction: { _, _, _ in
                let pb64 = """
                    cHNidP8BAIkBAAAAAeaWcxp4/+xSRJ2rhkpUJ+jQclqocoyuJ/ulSZEgEkaoAQAAAAD+////Ak/cDgAAAAAAIlEgqxShDO8ifAouGyRHTFxWnTjpY69Cssr3IoNQvMYOKG/OVgAAAAAAACJRIGnlvMwBz4Ylb6xLTe5g4ZeZCxmVH/XWG+CDlcPzzaoT8qoGAAABAStAQg8AAAAAACJRIFGGvSoLWt3hRAIwYa8KEyawiFTXoOCVWFxYtSofZuAsIRZ2b8YiEpzexWYGt8B5EqLM8BE4qxJY3pkiGw/8zOZGYxkAvh7sj1YAAIABAACAAAAAgAAAAAAEAAAAARcgdm/GIhKc3sVmBrfAeRKizPAROKsSWN6ZIhsP/MzmRmMAAQUge7cvJMsJmR56NzObGOGkm8vNqaAIJdnBXLZD2PvrinIhB3u3LyTLCZkeejczmxjhpJvLzamgCCXZwVy2Q9j764pyGQC+HuyPVgAAgAEAAIAAAACAAQAAAAYAAAAAAQUgtIFPrI2EW/+PJiAmYdmux88p0KgeAxDFLMoeQoS66hIhB7SBT6yNhFv/jyYgJmHZrsfPKdCoHgMQxSzKHkKEuuoSGQC+HuyPVgAAgAEAAIAAAACAAAAAAAIAAAAA
                    """
                return try Psbt(psbtBase64: pb64)
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
            setNeedsFullScan: { _ in },
            getNetwork: { .signet },
            getEsploraURL: { Constants.Networks.Signet.Mutiny.esploraServers.first ?? "" },
            updateNetwork: { _ in },
            updateEsploraURL: { _ in },
            getAddressType: { .bip86 },
            updateAddressType: { _ in },
            getClientType: { .esplora },
            updateClientType: { _ in }
        )
    }
#endif
