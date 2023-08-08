//
//  WalletViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/6/23.
//

import Foundation
import BitcoinDevKit

class WalletViewModel: ObservableObject {
    
    // Balance
    @Published var balanceTotal: UInt64 = 0
    
    // Sync
    @Published var lastSyncTime: Date? = nil
    @Published var walletSyncState: WalletSyncState = .notStarted
    
    // Transactions
    @Published var transactionDetails: [TransactionDetails] = []
    
    // Price
    @Published var price: Double = 0.0
    @Published var time: Int?
    @Published var satsPrice: String = "0"
    let priceService: PriceService
    
    init(priceService: PriceService) {
        self.priceService = priceService
    }
    
    func getPrices() async {
        do {
            let price = try await priceService.prices()
            DispatchQueue.main.async {
                self.price = price.usd
                self.time = price.time
            }
        } catch {
            print("getPrices error: \(error.localizedDescription)")
        }
    }
    
    private func valueInUSD() {
        self.satsPrice = Double(balanceTotal).valueInUSD(price: price)
    }
    
    func getBalance() {
        do {
            let balance = try BDKService.shared.getBalance()
            self.balanceTotal = balance.total
        } catch let error as WalletError {
            print("getBalance - Wallet Error: \(error.localizedDescription)")
        } catch {
            print("getBalance - Undefined Error: \(error.localizedDescription)")
        }
    }
    
    func getTransactions() {
        do {
            let transactionDetails = try BDKService.shared.getTransactions()
            self.transactionDetails = transactionDetails
        } catch {
            print("getTransactions - none: \(error.localizedDescription)")
        }
    }
    
    func sync() async {
        DispatchQueue.main.async {
            self.walletSyncState = .syncing
        }
        Task {
            do {
                try await BDKService.shared.sync()
                DispatchQueue.main.async {
                    self.walletSyncState = .synced
                    self.lastSyncTime = Date()
                    self.getBalance()
                    self.getTransactions()
                    self.valueInUSD()
                }
            } catch {
                DispatchQueue.main.async {
                    self.walletSyncState = .error(error)
                }
            }
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
