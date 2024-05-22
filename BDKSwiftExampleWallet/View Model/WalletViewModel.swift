//
//  WalletViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/6/23.
//

import BitcoinDevKit
import Foundation
import Observation

@MainActor
@Observable
class WalletViewModel {
    let priceClient: PriceClient
    let bdkClient: BDKClient

    var balanceTotal: UInt64 = 0
    var walletSyncState: WalletSyncState = .notStarted
    var transactions: [CanonicalTx] = []
    var price: Double = 0.00
    var time: Int?
    var satsPrice: String {
        let usdValue = Double(balanceTotal).valueInUSD(price: price)
        return usdValue
    }
    var walletViewError: AppError?
    var showingWalletViewErrorAlert = false

    var progress: Float = 0.0
    var inspectedScripts: UInt64 = 0
    var totalScripts: UInt64 = 0

    init(
        priceClient: PriceClient = .live,
        bdkClient: BDKClient = .live
    ) {
        self.priceClient = priceClient
        self.bdkClient = bdkClient
    }

    func getPrices() async {
        do {
            let price = try await priceClient.fetchPrice()
            self.price = price.usd
            self.time = price.time
        } catch {
            self.walletViewError = .generic(message: error.localizedDescription)
            self.showingWalletViewErrorAlert = true
        }
    }

    func getBalance() {
        do {
            let balance = try bdkClient.getBalance()
            self.balanceTotal = balance.total.toSat()
        } catch let error as WalletError {
            self.walletViewError = .generic(message: error.localizedDescription)
            self.showingWalletViewErrorAlert = true
        } catch {
            self.walletViewError = .generic(message: error.localizedDescription)
            self.showingWalletViewErrorAlert = true
        }
    }

    func getTransactions() {
        do {
            let transactionDetails = try bdkClient.transactions()
            self.transactions = transactionDetails
        } catch let error as WalletError {
            self.walletViewError = .generic(message: error.localizedDescription)
            self.showingWalletViewErrorAlert = true
        } catch {
            self.walletViewError = .generic(message: error.localizedDescription)
            self.showingWalletViewErrorAlert = true
        }
    }

    //    func fullScan() async {
    //        self.walletSyncState = .syncing
    //        do {
    //            try await bdkClient.fullScan()
    //            self.walletSyncState = .synced
    //        } catch let error as CannotConnectError {
    //            self.walletViewError = .generic(message: error.localizedDescription)
    //            self.showingWalletViewErrorAlert = true
    //        } catch let error as EsploraError {
    //            self.walletViewError = .generic(message: error.localizedDescription)
    //            self.showingWalletViewErrorAlert = true
    //        } catch let error as PersistenceError {
    //            self.walletViewError = .generic(message: error.localizedDescription)
    //            self.showingWalletViewErrorAlert = true
    //        } catch {
    //            self.walletSyncState = .error(error)
    //            self.showingWalletViewErrorAlert = true
    //        }
    //    }

    func fullScanWithProgress() async {
        self.walletSyncState = .syncing
        do {
            let inspector = MyScriptInspectorFullScan(updateProgress: updateProgressFullScan)
            try await bdkClient.fullScanWithInspector(inspector)
            self.walletSyncState = .synced
        } catch let error as CannotConnectError {
            self.walletViewError = .generic(message: error.localizedDescription)
            self.showingWalletViewErrorAlert = true
        } catch let error as EsploraError {
            self.walletViewError = .generic(message: error.localizedDescription)
            self.showingWalletViewErrorAlert = true
        } catch let error as PersistenceError {
            self.walletViewError = .generic(message: error.localizedDescription)
            self.showingWalletViewErrorAlert = true
        } catch {
            self.walletSyncState = .error(error)
            self.showingWalletViewErrorAlert = true
        }
    }
    //
    //    func sync() async {
    //        self.walletSyncState = .syncing
    //        do {
    //            try await bdkClient.sync()
    //            self.walletSyncState = .synced
    //        } catch let error as CannotConnectError {
    //            self.walletViewError = .generic(message: error.localizedDescription)
    //            self.showingWalletViewErrorAlert = true
    //        } catch let error as EsploraError {
    //            self.walletViewError = .generic(message: error.localizedDescription)
    //            self.showingWalletViewErrorAlert = true
    //        } catch let error as PersistenceError {
    //            self.walletViewError = .generic(message: error.localizedDescription)
    //            self.showingWalletViewErrorAlert = true
    //        } catch {
    //            self.walletSyncState = .error(error)
    //            self.showingWalletViewErrorAlert = true
    //        }
    //    }

    func startSyncWithProgress() async {
        self.walletSyncState = .syncing
        do {
            let inspector = MyScriptInspector(updateProgress: updateProgress)
            try await bdkClient.syncWithInspector(inspector)
            self.walletSyncState = .synced
        } catch let error as CannotConnectError {
            self.walletViewError = .generic(message: error.localizedDescription)
            self.showingWalletViewErrorAlert = true
        } catch let error as EsploraError {
            self.walletViewError = .generic(message: error.localizedDescription)
            self.showingWalletViewErrorAlert = true
        } catch let error as PersistenceError {
            self.walletViewError = .generic(message: error.localizedDescription)
            self.showingWalletViewErrorAlert = true
        } catch let error as RequestError {
            self.walletViewError = .generic(message: error.localizedDescription)
            self.showingWalletViewErrorAlert = true
        } catch {
            self.walletSyncState = .error(error)
            self.showingWalletViewErrorAlert = true
        }
    }

    func syncOrFullScan() async {
        if bdkClient.needsFullScan() {
            // If the flag is set, proceed with full scan
            await fullScanWithProgress()
            bdkClient.setNeedsFullScan(false)  // Reset the flag after the full scan
        } else {
            // Otherwise, proceed with sync
            await startSyncWithProgress()
        }
    }

    func updateProgress(inspected: UInt64, total: UInt64) {
        DispatchQueue.main.async {
            self.totalScripts = total
            self.inspectedScripts = inspected
            self.progress = total > 0 ? Float(inspected) / Float(total) : 0
        }
    }

    func updateProgressFullScan(inspected: UInt64) {
        DispatchQueue.main.async {
            self.inspectedScripts = inspected
        }
    }

}

class MyScriptInspector: ScriptInspector {
    private let updateProgress: (UInt64, UInt64) -> Void
    private var inspectedCount: UInt64 = 0
    private var totalCount: UInt64 = 0

    init(updateProgress: @escaping (UInt64, UInt64) -> Void) {
        self.updateProgress = updateProgress
    }

    func inspect(script: Script, total: UInt64) {
        totalCount = total
        inspectedCount += 1
        updateProgress(inspectedCount, totalCount)
        Thread.sleep(forTimeInterval: 1.5)
    }
}

class MyScriptInspectorFullScan: ScriptInspectorFullScan {
    private let updateProgress: (UInt64) -> Void
    private var inspectedCount: UInt64 = 0

    init(updateProgress: @escaping (UInt64) -> Void) {
        self.updateProgress = updateProgress
    }

    func inspect(keychain: KeychainKind, index: UInt32, script: Script) {
        inspectedCount += 1
        updateProgress(inspectedCount)
        Thread.sleep(forTimeInterval: 1.5)
    }
}
