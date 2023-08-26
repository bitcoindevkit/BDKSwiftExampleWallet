//
//  WalletViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/6/23.
//

import Foundation
import BitcoinDevKit
import Observation

@MainActor
@Observable
class WalletViewModel {
    var balanceTotal: UInt64 = 0
    var lastSyncTime: Date? = nil
    var walletSyncState: WalletSyncState = .notStarted
    var transactionDetails: [TransactionDetails] = []
    var price: Double = 0.0
    var time: Int?
    var satsPrice: String {
        let usdValue = Double(balanceTotal).valueInUSD(price: price)
        return usdValue
    }
    let priceService: PriceAPIService//PriceService
    
    init(priceService: PriceAPIService) {
        self.priceService = priceService
    }
    
    func getPrices() async {
        print("===")
        print("getPrices() called")
        do {
            let price = try await priceService.fetchPrice()//priceService.prices()
            self.price = price.usd
            self.time = price.time
            print("Price USD: \(self.price)")
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
            let balance = try BDKService.shared.getBalance()
            print("Balance: \(balance)")
            self.balanceTotal = balance.total
            print("Balance Total: \(self.balanceTotal)")
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
            let transactionDetails = try BDKService.shared.getTransactions()
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
            try await BDKService.shared.sync()
            self.walletSyncState = .synced
            self.lastSyncTime = Date()
            print("Wallet Sync State: \(self.walletSyncState)")
            print("Last Sync Time: \(String(describing: self.lastSyncTime))")
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
        
        static func ==(lhs: WalletSyncState, rhs: WalletSyncState) -> Bool {
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
