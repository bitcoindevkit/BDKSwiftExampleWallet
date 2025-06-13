//
//  WalletViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/6/23.
//

import BitcoinDevKit
import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
class WalletViewModel {
    let bdkClient: BDKClient
    let keyClient: KeyClient
    let priceClient: PriceClient

    var balanceTotal: UInt64 = 0
    var canSend: Bool {
        guard let backupInfo = try? keyClient.getBackupInfo() else { return false }
        return backupInfo.descriptor.contains("tprv") || backupInfo.descriptor.contains("xprv")
    }
    var inspectedScripts: UInt64 = 0
    var price: Double = 0.00
    var progress: Float = 0.0
    var recentTransactions: [CanonicalTx] {
        let maxTransactions = UIScreen.main.isPhoneSE ? 4 : 5
        return Array(transactions.prefix(maxTransactions))
    }
    var satsPrice: Double {
        let usdValue = Double(balanceTotal).valueInUSD(price: price)
        return usdValue
    }
    var showingWalletViewErrorAlert = false
    var time: Int?
    var totalScripts: UInt64 = 0
    var transactions: [CanonicalTx]
    var walletSyncState: WalletSyncState
    var walletViewError: AppError?
    var needsFullScan: Bool {
        bdkClient.needsFullScan()
    }
    var syncMode: SyncMode {
        bdkClient.getSyncMode() ?? .esplora
    }

    init(
        bdkClient: BDKClient = .live,
        keyClient: KeyClient = .live,
        priceClient: PriceClient = .live,
        transactions: [CanonicalTx] = [],
        walletSyncState: WalletSyncState = .notStarted
    ) {
        self.bdkClient = bdkClient
        self.keyClient = keyClient
        self.priceClient = priceClient
        self.transactions = transactions
        self.walletSyncState = walletSyncState
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

    func syncOrFullScan() async {
        if bdkClient.needsFullScan() {
            await fullScanWithProgress()
            bdkClient.setNeedsFullScan(false)
        } else {
            await startSyncWithProgress()
        }
    }

    private func startSyncWithProgress() async {
        self.walletSyncState = .syncing
        do {
            try await bdkClient.syncScanWithSyncScanProgress { [weak self] inspected, total in
                self?.updateSyncProgress(inspected, total)
            }
            self.walletSyncState = .synced
        } catch let error as CannotConnectError {
            self.walletViewError = .generic(message: error.localizedDescription)
            self.showingWalletViewErrorAlert = true
        } catch let error as EsploraError {
            self.walletViewError = .generic(message: error.localizedDescription)
            self.showingWalletViewErrorAlert = true
        } catch let error as RequestBuilderError {
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

    private func fullScanWithProgress() async {
        self.walletSyncState = .syncing
        do {
            try await bdkClient.fullScanWithFullScanProgress { [weak self] progress in
                self?.updateFullProgress(progress)
            }
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

    private func updateFullProgress(_ progress: UInt64) {
        DispatchQueue.main.async { [weak self] in
            self?.inspectedScripts = progress
        }
    }

    private func updateSyncProgress(_ inspected: UInt64, _ total: UInt64) {
        DispatchQueue.main.async { [weak self] in
            self?.totalScripts = total
            self?.inspectedScripts = inspected
            self?.progress = total > 0 ? Float(inspected) / Float(total) : 0
        }
    }

}
