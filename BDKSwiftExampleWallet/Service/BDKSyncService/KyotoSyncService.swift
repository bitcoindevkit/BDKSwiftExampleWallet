//
//  KyotoSyncService.swift
//  BDKSwiftExampleWallet
//
//  Created by Rubens Machion on 16/05/25.
//

import BitcoinDevKit
import Foundation

final class KyotoSyncService: BDKSyncService {
    
    var connection: Connection?
    var keyClient: KeyClient
    var network: Network
    var wallet: Wallet?
    
    private var node: CbfNode?
    private var client: CbfClient?
    
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
        self.wallet = try buildWallet(params: params)
    }
    
    func loadWallet() throws {
        
    }
    
    func deleteWallet() throws {
        
    }
    
    func updateNetwork(network: Network) {
        self.network = network
    }
    
    func startSync(progress: SyncScriptInspector) async throws {
        
    }
    
    func startFullScan(progress: FullScanScriptInspector) async throws {
        
    }
    
    func getTransactions() throws -> [CanonicalTx] {
        []
    }
    
    func getBalance() throws -> Balance {
        fatalError("Missing implementation")
    }
}
