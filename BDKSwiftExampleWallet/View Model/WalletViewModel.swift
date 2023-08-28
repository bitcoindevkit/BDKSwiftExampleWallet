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
    var transactionDetails: [TransactionDetails] = []
    var price: Double = 0.00//?
    var time: Int?
    var satsPrice: String {
        let usdValue = Double(balanceTotal).valueInUSD(price: price)
        return usdValue
    }

    init(priceClient: PriceClient = .live, bdkClient: BDKClient = .live) {
        self.priceClient = priceClient
        self.bdkClient = bdkClient
    }

    func getPrices() async {
        print("===")
        print("getPrices() called")
        do {
            let price = try await priceClient.fetchPrice()
            self.price = price.usd
            self.time = price.time
            print("Price USD: \(String(describing: self.price))")
            print("Price Time: \(String(describing: self.time))")
        } catch {
            print("getPrices error: \(error.localizedDescription)")
        }
        print("===")
    }

    func getBalance() {
        print("===")
        print("getBalance() called")
        do {
            let balance = try bdkClient.getBalance()
            print("Balance: \(balance)")
            self.balanceTotal = balance.total
            print("Balance Total: \(String(describing: self.balanceTotal))")
        } catch let error as WalletError {
            print("getBalance - Wallet Error: \(error.localizedDescription)")
        } catch {
            print("getBalance - Undefined Error: \(error.localizedDescription)")
        }
        print("===")
    }

    func getTransactions() {
        print("===")
        print("getTransactions() called")
        do {
            let transactionDetails = try bdkClient.getTransactions()
            self.transactionDetails = transactionDetails
            print("Transaction Details: \(self.transactionDetails)")
        } catch {
            print("getTransactions - none: \(error.localizedDescription)")
        }
        print("===")
    }

    func sync() async {
        print("===")
        print("sync() called")
        self.walletSyncState = .syncing
        do {
            try await bdkClient.sync()
            self.walletSyncState = .synced
            print("Wallet Sync State: \(self.walletSyncState)")
        } catch {
            self.walletSyncState = .error(error)
        }
        print("===")
    }

}

extension WalletViewModel {
    enum WalletSyncState: CustomStringConvertible, Equatable {
        case error(Error)
        case notStarted
        case synced
        case syncing

        var description: String {
            switch self {
            case .error(let error):
                return "Error Syncing: \(error.localizedDescription)"
            case .notStarted:
                return "Not Started"
            case .synced:
                return "Synced"
            case .syncing:
                return "Syncing"
            }
        }

        static func == (lhs: WalletSyncState, rhs: WalletSyncState) -> Bool {
            switch (lhs, rhs) {
            case (.error(let error1), .error(let error2)):
                return error1.localizedDescription == error2.localizedDescription
            case (.notStarted, .notStarted):
                return true
            case (.synced, .synced):
                return true
            case (.syncing, .syncing):
                return true
            default:
                return false
            }
        }
    }
}
