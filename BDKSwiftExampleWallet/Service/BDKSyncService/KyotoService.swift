//
//  KyotoService.swift
//  BDKSwiftExampleWallet
//
//  Created by Rubens Machion on 24/05/25.
//

import BitcoinDevKit
import Foundation

final class KyotoService: BDKSyncService {
    
    private static let nodeHeight: UInt32 = 253_000
    
    static let shared = KyotoService()
    
    var connection: Connection?
    var keyClient: KeyClient
    var network: Network
    var wallet: Wallet?
    
    private var client: CbfClient?
    private var node: CbfNode?
    private var connected = false
    
    private var fullScanProgress2: FullScanProgress?
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
        guard let wallet = self.wallet else {
            throw WalletError.walletNotFound
        }
        let nodeComponents = try buildNode(
            from: wallet, scanType: .sync
        )
        self.syncProgress = progress
        self.client = nodeComponents.client
        self.node = nodeComponents.node
        try await startListen()
    }
    
    func startFullScan(progress: @escaping FullScanProgress) async throws {
        guard let wallet = self.wallet else {
            throw WalletError.walletNotFound
        }
        let nodeComponents = try buildNode(
            from: wallet, scanType: .recovery(fromHeight: KyotoService.nodeHeight)
        )
        self.fullScanProgress2 = progress
        self.client = nodeComponents.client
        self.node = nodeComponents.node
        try await startListen()
    }
    
    func send(address: String, amount: UInt64, feeRate: UInt64) async throws {
        
    }
    
    // MARK: - Private
    
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
        guard let update = await self.client?.update() else { return false }
        try self.wallet?.applyUpdate(update: update)
        let _ = try self.wallet?.persist(connection: self.connection ?? Connection.loadConnection())
        print("######### walletUpdated")
        
        return true
    }
    
//    private func continuallyUpdate() async {
//        Task {
//            while true {
//                guard let update = await self.client?.update() else { return }
//                try self.wallet?.applyUpdate(update: update)
//                let _ = try self.wallet?.persist(connection: self.connection ?? Connection.loadConnection())
//                print("######### walletUpdated")
////                DispatchQueue.main.async {
////                    NotificationCenter.default.post(name: .walletUpdated, object: nil)
////                }
//            }
//        }
//    }
    
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
                        if let fullScanProgress = self.fullScanProgress2 {
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
                if let warn = try? await self.client!.nextWarning() {
                    switch warn {
                    case .needConnections:
                        print("######### disconnected")
                        self.connected = false
//                        DispatchQueue.main.async {
//                            NotificationCenter.default.post(name: .connectionsChanged, object: nil)
//                        }
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
