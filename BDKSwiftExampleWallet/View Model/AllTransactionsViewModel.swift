//
//  AllTransactionsViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/4/24.
//

import BitcoinDevKit
import Foundation

@MainActor
@Observable
class AllTransactionsViewModel {
    let bdkClient: BDKClient
    var walletSyncState: WalletSyncState
    var transactions: [CanonicalTx]
    var walletViewError: AppError?
    var showingWalletViewErrorAlert = false
    var progress: Float = 0.0
    var inspectedScripts: UInt64 = 0
    var totalScripts: UInt64 = 0
    var utxos: [LocalOutput] = []
    var displayMode: DisplayMode = .transactions

    enum DisplayMode {
        case transactions
        case utxos
    }

    init(
        bdkClient: BDKClient = .live,
        walletSyncState: WalletSyncState = .notStarted,
        transactions: [CanonicalTx] = []
    ) {
        self.bdkClient = bdkClient
        self.walletSyncState = walletSyncState
        self.transactions = transactions
    }

    func getUTXOs() {
        do {
            self.utxos = try bdkClient.listUnspent()
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

    private func startSyncWithProgress() async {
        self.walletSyncState = .syncing
        do {
            let inspector = WalletSyncScriptInspector(updateProgress: updateProgress)
            try await bdkClient.syncWithInspector(inspector)
            self.walletSyncState = .synced
        } catch let error as CannotConnectError {
            self.walletViewError = .generic(message: error.localizedDescription)
            self.showingWalletViewErrorAlert = true
        } catch let error as EsploraError {
            self.walletViewError = .generic(message: error.localizedDescription)
            self.showingWalletViewErrorAlert = true
        } catch let error as InspectError {
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

    func syncOrFullScan() async {
        await startSyncWithProgress()
    }

    private func updateProgress(inspected: UInt64, total: UInt64) {
        DispatchQueue.main.async {
            self.totalScripts = total
            self.inspectedScripts = inspected
            self.progress = total > 0 ? Float(inspected) / Float(total) : 0
        }
    }

}
