//
//  Untitled.swift
//  BDKSwiftExampleWallet
//
//  Created by Rubens Machion on 16/05/25.
//

import BitcoinDevKit
import Foundation

final class EsploraServerSyncService: BDKSyncService {
    
    var connection: Connection?
    var keyClient: KeyClient
    var network: Network
    var wallet: Wallet?
    var needsFullScan = false
    
    private var esploraClient: EsploraClient
    
    init(
        keyClient: KeyClient = .live,
        network: Network = .signet,
        connection: Connection? = nil
    ) {
        self.connection = connection
        self.keyClient = keyClient
        self.network = network
        
        let url = (try? keyClient.getEsploraURL()) ?? network.url
        self.esploraClient = .init(
            url: url
        )
    }
    
    func createWallet(params: String?) throws {
        self.wallet = try buildWallet(params: params)
    }
    
    func loadWallet() throws {
        
    }
    
    func deleteWallet() throws {
        
    }
}
