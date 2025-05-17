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
        self.connection = try Connection.createConnection()
        self.wallet = try buildWallet(params: params)
    }
    
    func loadWallet() throws {
        self.connection = try Connection.loadConnection()
        let wallet = try loadWalleFromBackup()
        self.wallet = wallet
    }
    
    func deleteWallet() throws {
        try deleteData()
    }
    
    func updateNetwork(network: Network) {
        self.network = network
    }
    
    func updateEsploraURL(_ url: String) {
        try? keyClient.saveEsploraURL(url)
        self.esploraClient = .init(url: url)
    }
    
    func startSync(progress: SyncScriptInspector) async throws {
        guard let wallet = self.wallet else { throw WalletError.walletNotFound }
        let esploraClient = self.esploraClient
        let syncRequest = try wallet.startSyncWithRevealedSpks()
            .inspectSpks(inspector: progress)
            .build()
        let update = try esploraClient.sync(
            request: syncRequest,
            parallelRequests: UInt64(5)
        )
        let _ = try wallet.applyUpdate(update: update)
        guard let connection = self.connection else {
            throw WalletError.dbNotFound
        }
        let _ = try wallet.persist(connection: connection)
    }
    
    func startFullScan(progress: FullScanScriptInspector) async throws {
        guard let wallet = self.wallet else { throw WalletError.walletNotFound }
        let esploraClient = esploraClient
        let fullScanRequest = try wallet.startFullScan()
            .inspectSpksForAllKeychains(inspector: progress)
            .build()
        let update = try esploraClient.fullScan(
            request: fullScanRequest,
            // using https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki#address-gap-limit
            stopGap: UInt64(20),
            // using https://github.com/bitcoindevkit/bdk/blob/master/example-crates/example_wallet_esplora_blocking/src/main.rs
            parallelRequests: UInt64(5)
        )
        let _ = try wallet.applyUpdate(update: update)
        guard let connection = self.connection else {
            throw WalletError.dbNotFound
        }
        let _ = try wallet.persist(connection: connection)
    }
    
    func getTransactions() throws -> [CanonicalTx] {
        guard let wallet = self.wallet else {
            throw WalletError.walletNotFound
        }
        let transactions = wallet.transactions()
        let sortedTransactions = transactions.sorted { (tx1, tx2) in
            return tx1.chainPosition.isBefore(tx2.chainPosition)
        }
        return sortedTransactions
    }
    
    func getBalance() throws -> Balance {
        guard let wallet = self.wallet else { throw WalletError.walletNotFound }
        let balance = wallet.balance()
        return balance
    }
}
