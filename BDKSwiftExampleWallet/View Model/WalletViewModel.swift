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
            self.balanceTotal = balance.total
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

    func sync() async {
        self.walletSyncState = .syncing
        do {
            try await bdkClient.sync()
            self.walletSyncState = .synced
        } catch {
            self.walletSyncState = .error(error)
            self.showingWalletViewErrorAlert = true
        }
    }

}
