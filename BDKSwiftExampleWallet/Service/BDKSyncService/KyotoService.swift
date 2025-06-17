//
//  KyotoService.swift
//  BDKSwiftExampleWallet
//
//  Created by Rubens Machion on 24/05/25.
//

import BitcoinDevKit
import Foundation

extension KyotoService {
    static var live: BDKSyncService = KyotoService()
}

extension Notification.Name {
    static let walletDidUpdate = Notification.Name("walletDidUpdate")
    static let walletDidConnect = Notification.Name("walletDidConnect")
    static let walletDidDisconnect = Notification.Name("walletDidDisconnect")
}

final class KyotoService: BDKSyncService {

    static let shared: KyotoService = .init()
    
    var connection: Connection?
    var keyClient: KeyClient
    var network: Network
    var wallet: Wallet?

    private var client: CbfClient?
    private var node: CbfNode?
    private var isConnected = false {
        didSet {
            isConnected ?
            NotificationCenter.default.post(name: .walletDidConnect, object: nil) :
            NotificationCenter.default.post(name: .walletDidDisconnect, object: nil)
        }
    }
    private var isScanRunning = false

    private var fullScanProgress: FullScanProgress?
    private var syncProgress: SyncScanProgress?

    init(
        keyClient: KeyClient = .live,
        network: Network = .signet,
        connection: Connection? = nil
    ) {
        self.connection = connection
        self.keyClient = keyClient
        self.network = network
    }

    func createWallet(params: String?) throws {
        self.connection = try Connection.createConnection()
        self.wallet = try buildWallet(params: params)
    }

    func loadWallet() throws {
        self.connection = try Connection.loadConnection()
        let wallet = try loadWalleFromBackup()
        self.wallet = wallet
    }

    func startSync(progress: @escaping SyncScanProgress) async throws {
        if isScanRunning { return }
        guard let wallet = self.wallet else {
            throw WalletError.walletNotFound
        }
        let nodeComponents = try buildNode(
            from: wallet,
            scanType: .sync
        )
        self.syncProgress = progress
        self.client = nodeComponents.client
        self.node = nodeComponents.node
        isScanRunning = true
        try await startNode()
    }

    func startFullScan(progress: @escaping FullScanProgress) async throws {
        if isScanRunning { return }
        guard let wallet = self.wallet else {
            throw WalletError.walletNotFound
        }
        let nodeComponents = try buildNode(
            from: wallet,
            scanType: .recovery(fromHeight: network.taprootHeight)
        )

        self.fullScanProgress = progress
        self.client = nodeComponents.client
        self.node = nodeComponents.node
        isScanRunning = true
        try await startNode()
    }

    func send(address: String, amount: UInt64, feeRate: UInt64) async throws {
        let psbt = try buildTransaction(
            address: address,
            amount: amount,
            feeRate: feeRate
        )
        try await signAndBroadcast(psbt: psbt)
    }

    func stopService() async throws {
        isScanRunning = false
        try await client?.shutdown()
    }

    // MARK: - Private

    private func signAndBroadcast(psbt: Psbt) async throws {
        guard let wallet = self.wallet else { throw WalletError.walletNotFound }
        let isSigned = try wallet.sign(psbt: psbt)
        if isSigned {
            let transaction = try psbt.extractTx()
            try await client?.broadcast(transaction: transaction)
        } else {
            throw WalletError.notSigned
        }
    }

    private func buildNode(from wallet: Wallet, scanType: ScanType) throws -> CbfComponents {
        try CbfBuilder()
            .dataDir(dataDir: Connection.dataDir)
            .logLevel(logLevel: .debug)
            .scanType(scanType: scanType)
            .build(wallet: wallet)
    }

    private func startNode() async throws {
        node?.run()
        printLogs()
        updateWarn()
        try await updateWallet()
        startRealTimeWalletUpdate()
    }

    @discardableResult
    private func updateWallet() async throws -> Bool {
        guard let update = await self.client?.update() else {
            isScanRunning = false
            print("Nothing to update")
            return false
        }
        try self.wallet?.applyUpdate(update: update)
        let _ = try self.wallet?.persist(connection: self.connection ?? Connection.loadConnection())
        print("######### walletUpdated")
        isScanRunning = false
        return true
    }
    
    private func startRealTimeWalletUpdate() {
        print(#function)
        Task {
            while true {
                print("Updating: \(Date())")
                if let update = await client?.update() {
                    do {
                        try wallet?.applyUpdate(update: update)
                        NotificationCenter.default.post(name: .walletDidUpdate, object: nil)
                        print("Updated wallet")
                    } catch {
                        print(error)
                    }
                } else {
                    print("Nothing to update")
                }
            }
        }
    }
    
    private func printLogs() {
        Task {
            while true {
                if let log = try? await self.client?.nextLog() {
                    print("\(log)")
                    switch log {
                    case .connectionsMet:
                        print("######### connected")
                        self.isConnected = true
                    case .progress(let progress):
                        if let fullScanProgress = self.fullScanProgress {
                            let _progress = UInt64(progress * 100.0)
                            fullScanProgress(_progress)
                        }
                    default:
                        break
                    }
                }
            }
        }
    }

    private func updateWarn() {
        Task {
            while true {
                if let warn = try? await self.client?.nextWarning() {
                    switch warn {
                    case .needConnections:
                        print("######### disconnected")
                        self.isConnected = false
                    default:
                        #if DEBUG
                            print(warn)
                        #endif
                    }
                }
            }
        }
    }
}
