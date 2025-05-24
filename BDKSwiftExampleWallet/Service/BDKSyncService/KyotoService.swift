//
//  KyotoService.swift
//  BDKSwiftExampleWallet
//
//  Created by Rubens Machion on 24/05/25.
//

import BitcoinDevKit
import Foundation

final class KyotoService: BDKSyncService {
    
    static let shared = KyotoService()
    
    var connection: Connection?
    var keyClient: KeyClient
    var network: Network
    var wallet: Wallet?
    
    private var client: CbfClient?
    private var node: CbfNode?
    private var connected = false
    
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
        
        let nodeComponents = try buildNode(from: wallet)
        self.client = nodeComponents.client
        self.node = nodeComponents.node
        startListen()
    }
    
    func deleteWallet() throws {
        
    }
    
    func startSync(progress: any SyncScriptInspector) async throws {
        
    }
    
    func startFullScan(progress: any FullScanScriptInspector) async throws {
        
    }
    
    func getTransactions() throws -> [CanonicalTx] {
        []
    }
    
    func getBalance() throws -> Balance {
        .mock
    }
    
    func sentAndReceived(tx: Transaction) throws -> SentAndReceivedValues {
        .mock
    }
    
    func calculateFeeRate(tx: Transaction) throws -> UInt64 {
        .zero
    }
    
    func calculateFee(tx: Transaction) throws -> Amount {
        try .fromBtc(btc: .zero)
    }
    
    func buildTransaction(address: String, amount: UInt64, feeRate: UInt64) throws -> Psbt {
        .init(noPointer: .init())
    }
    
    func send(address: String, amount: UInt64, feeRate: UInt64) async throws {
        
    }
    
    func listUnspent() throws -> [LocalOutput] {
        []
    }
    
    func getAddress() throws -> String {
        ""
    }
    
    // MARK: - Private
    
    private func buildNode(from wallet: Wallet) throws -> CbfComponents {
        try CbfBuilder()
            .dataDir(dataDir: Connection.dataDir)
            .logLevel(logLevel: .debug)
            .scanType(scanType: .recovery(fromHeight: 200_000))
            .build(wallet: wallet)
    }
    
    private func startListen() {
        node?.run()
        continuallyUpdate()
        printLogs()
        updateWarn()
    }
    
    private func continuallyUpdate() {
        Task {
            while true {
                guard let update = await self.client?.update() else { return }
                try self.wallet?.applyUpdate(update: update)
                let _ = try self.wallet?.persist(connection: self.connection ?? Connection.loadConnection())
                print("######### walletUpdated")
//                DispatchQueue.main.async {
//                    NotificationCenter.default.post(name: .walletUpdated, object: nil)
//                }
            }
        }
    }
    
    private func printLogs() {
        Task {
            while true {
                if let log = try? await self.client?.nextLog() {
                    print("\(log)")
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
                        print("######### connectionsChanged")
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
