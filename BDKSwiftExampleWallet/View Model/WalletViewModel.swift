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
    var isKyotoClient: Bool {
        bdkClient.getClientType() == .kyoto
    }
    var isKyotoConnected: Bool = false
    var currentBlockHeight: UInt32 = 0

    private var updateProgress: @Sendable (UInt64, UInt64) -> Void {
        { [weak self] inspected, total in
            DispatchQueue.main.async {
                self?.totalScripts = total
                self?.inspectedScripts = inspected
                self?.progress = total > 0 ? Float(inspected) / Float(total) : 0
            }
        }
    }

    private var updateKyotoProgress: @Sendable (Float) -> Void {
        { [weak self] progress in
            DispatchQueue.main.async {
                self?.progress = progress
                let progressPercent = UInt64(progress)
                self?.inspectedScripts = progressPercent
                self?.totalScripts = 100
            }
        }
    }

    private var updateProgressFullScan: @Sendable (UInt64) -> Void {
        { [weak self] inspected in
            DispatchQueue.main.async {
                self?.inspectedScripts = inspected
            }
        }
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

        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("KyotoProgressUpdate"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self else { return }
            // Ignore Kyoto updates unless client type is Kyoto
            if self.bdkClient.getClientType() != .kyoto { return }
            if let progress = notification.userInfo?["progress"] as? Float {
                self.updateKyotoProgress(progress)
                
                // Update sync state based on Kyoto progress
                if progress >= 100 {
                    self.walletSyncState = .synced
                } else if progress > 0 {
                    self.walletSyncState = .syncing
                }
            }
        }

        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("KyotoConnectionUpdate"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let connected = notification.userInfo?["connected"] as? Bool {
                self?.isKyotoConnected = connected
                
                // When Kyoto connects, update sync state if needed
                if connected && self?.walletSyncState == .notStarted {
                    // Check current progress to determine state
                    if let progress = self?.progress, progress >= 100 {
                        self?.walletSyncState = .synced
                    } else {
                        self?.walletSyncState = .syncing
                    }
                }
            }
        }

        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("KyotoChainHeightUpdate"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self else { return }
            // Ignore Kyoto updates unless client type is Kyoto
            if self.bdkClient.getClientType() != .kyoto { return }
            if let height = notification.userInfo?["height"] as? UInt32 {
                self.currentBlockHeight = height
                // Auto-refresh wallet data when Kyoto receives new blocks
                self.getBalance()
                self.getTransactions()
                Task {
                    await self.getPrices()
                }
            }
        }
    }

    private func fullScanWithProgress() async {
        self.walletSyncState = .syncing
        do {
            let inspector = WalletFullScanScriptInspector(updateProgress: updateProgressFullScan)
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
        if bdkClient.needsFullScan() {
            await fullScanWithProgress()
            bdkClient.setNeedsFullScan(false)
        } else {
            await startSyncWithProgress()
        }
    }
}
