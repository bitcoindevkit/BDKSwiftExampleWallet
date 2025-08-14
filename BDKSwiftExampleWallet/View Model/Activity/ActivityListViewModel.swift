//
//  ActivityListViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/4/24.
//

import BitcoinDevKit
import Foundation

@MainActor
@Observable
class ActivityListViewModel {
    let bdkClient: BDKClient

    var displayMode: DisplayMode = .transactions
    var inspectedScripts: UInt64 = 0
    var localOutputs: [LocalOutput] = []
    var progress: Float = 0.0
    var transactions: [CanonicalTx]
    var showingWalletViewErrorAlert = false
    var totalScripts: UInt64 = 0
    var walletSyncState: WalletSyncState
    var walletViewError: AppError?

    private var updateProgress: @Sendable (UInt64, UInt64) -> Void {
        { [weak self] inspected, total in
            DispatchQueue.main.async {
                self?.totalScripts = total
                self?.inspectedScripts = inspected
                self?.progress = total > 0 ? Float(inspected) / Float(total) : 0
            }
        }
    }

    enum DisplayMode {
        case transactions
        case outputs
    }

    init(
        bdkClient: BDKClient = .live,
        transactions: [CanonicalTx] = [],
        walletSyncState: WalletSyncState = .notStarted
    ) {
        self.bdkClient = bdkClient
        self.transactions = transactions
        self.walletSyncState = walletSyncState

        // Preload cached data synchronously so UI has content before first render
        // transactions + listUnspent items are available from the persisted wallet db
        if self.transactions.isEmpty {
            if let cached = try? bdkClient.transactions() {
                self.transactions = cached
            }
        }
        if self.localOutputs.isEmpty {
            if let cachedUtxos = try? bdkClient.listUnspent() {
                self.localOutputs = cachedUtxos
            }
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

    func listUnspent() {
        do {
            self.localOutputs = try bdkClient.listUnspent()
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

    func syncOrFullScan() async {
        self.walletSyncState = .syncing
        await startSyncWithProgress()
    }
}
