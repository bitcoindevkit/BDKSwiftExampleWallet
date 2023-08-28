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
        do {
            let price = try await priceClient.fetchPrice()
            self.price = price.usd
            self.time = price.time
        } catch {
            print("getPrices error: \(error.localizedDescription)")
        }
    }

    func getBalance() {
        do {
            let balance = try bdkClient.getBalance()
            self.balanceTotal = balance.total
        } catch let error as WalletError {
            print("getBalance - Wallet Error: \(error.localizedDescription)")
        } catch {
            print("getBalance - Undefined Error: \(error.localizedDescription)")
        }
    }

    func getTransactions() {
        do {
            let transactionDetails = try bdkClient.getTransactions()
            self.transactionDetails = transactionDetails
        } catch {
            print("getTransactions - none: \(error.localizedDescription)")
        }
    }

    func sync() async {
        self.walletSyncState = .syncing
        do {
            try await bdkClient.sync()
            self.walletSyncState = .synced
        } catch {
            self.walletSyncState = .error(error)
        }
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
