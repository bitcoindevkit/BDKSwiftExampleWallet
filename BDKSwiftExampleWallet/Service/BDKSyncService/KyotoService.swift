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

final class KyotoService: BDKSyncService {

    static let shared: KyotoService = .init()
    
    var connection: Connection?
    var keyClient: KeyClient
    var network: Network
    var wallet: Wallet?

    private var client: CbfClient?
    private var node: CbfNode?
    private var connected = false
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
        try await startListen()
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
        try await startListen()
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

    private func startListen() async throws {
        node?.run()
        printLogs()
        updateWarn()
        try await startUpdating()
    }

    @discardableResult
    func startUpdating() async throws -> Bool {
        guard let update = await self.client?.update() else {
            isScanRunning = false
            return false
        }
        try self.wallet?.applyUpdate(update: update)
        let _ = try self.wallet?.persist(connection: self.connection ?? Connection.loadConnection())
        print("######### walletUpdated")
        isScanRunning = false
        return true
    }

    private func printLogs() {
        Task {
            while true {
                if let log = try? await self.client?.nextLog() {
                    print("\(log)")
                    switch log {
                    case .connectionsMet:
                        print("######### connected")
                        self.connected = true
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
                        self.connected = false
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
