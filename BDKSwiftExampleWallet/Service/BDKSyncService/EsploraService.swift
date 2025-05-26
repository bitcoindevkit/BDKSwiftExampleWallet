//
//  Untitled.swift
//  BDKSwiftExampleWallet
//
//  Created by Rubens Machion on 16/05/25.
//

import BitcoinDevKit
import Foundation

extension EsploraService {
    static var live: BDKSyncService = EsploraService()
}

final class EsploraService: BDKSyncService {
    
    static let shared = EsploraService()
    
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
    
    func updateNetwork(network: Network) {
        self.network = network
    }
    
    func updateEsploraURL(_ url: String) {
        try? keyClient.saveEsploraURL(url)
        self.esploraClient = .init(url: url)
    }
    
    func startSync(progress: @escaping SyncScanProgress) async throws {
        guard let wallet = self.wallet else { throw WalletError.walletNotFound }
        let syncScanInspector = WalletSyncScriptInspector { scripts, total in
            progress(scripts, total)
        }
        let esploraClient = self.esploraClient
        let syncRequest = try wallet.startSyncWithRevealedSpks()
            .inspectSpks(inspector: syncScanInspector)
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
    
    func startFullScan(progress: @escaping FullScanProgress) async throws {
        guard let wallet = self.wallet else { throw WalletError.walletNotFound }
        let fullScanInspector = WalletFullScanScriptInspector { inspected in
            progress(inspected)
        }
        let esploraClient = esploraClient
        let fullScanRequest = try wallet.startFullScan()
            .inspectSpksForAllKeychains(inspector: fullScanInspector)
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
    
    // MARK: - Private
    
    private func signAndBroadcast(psbt: Psbt) throws {
        guard let wallet = self.wallet else { throw WalletError.walletNotFound }
        let isSigned = try wallet.sign(psbt: psbt)
        if isSigned {
            let transaction = try psbt.extractTx()
            let client = self.esploraClient
            try client.broadcast(transaction: transaction)
        } else {
            throw WalletError.notSigned
        }
    }
}
