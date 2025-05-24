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
        
    }
    
    func loadWallet() throws {
        
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
}
