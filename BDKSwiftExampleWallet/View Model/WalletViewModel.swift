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
    
    private let bdkSyncService: BDKSyncService
    private(set) var isNeedFullScan: Bool
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

    private var updateProgress: @Sendable (UInt64, UInt64) -> Void {
        { [weak self] inspected, total in
            DispatchQueue.main.async {
                self?.totalScripts = total
                self?.inspectedScripts = inspected
                self?.progress = total > 0 ? Float(inspected) / Float(total) : 0
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
        keyClient: KeyClient = .live,
        priceClient: PriceClient = .live,
        transactions: [CanonicalTx] = [],
        walletSyncState: WalletSyncState = .notStarted,
        bdkSyncService: BDKSyncService,
        isNeedFullScan: Bool
    ) {
        self.keyClient = keyClient
        self.priceClient = priceClient
        self.transactions = transactions
        self.walletSyncState = walletSyncState
        self.bdkSyncService = bdkSyncService
        self.isNeedFullScan = isNeedFullScan
    }

    private func fullScanWithProgress() async {
        self.walletSyncState = .syncing
        do {
            let inspector = WalletFullScanScriptInspector(updateProgress: updateProgressFullScan)
            try await bdkSyncService.startFullScan(progress: inspector)
            
            isNeedFullScan = false
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
            let balance = try bdkSyncService.getBalance()
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
            let transactionDetails = try bdkSyncService.getTransactions()
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
            try await bdkSyncService.startSync(progress: inspector)
            
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
        if isNeedFullScan {
            await fullScanWithProgress()
        } else {
            await startSyncWithProgress()
        }
    }
}
