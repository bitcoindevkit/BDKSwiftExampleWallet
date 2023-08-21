//
//  SendViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/6/23.
//

import Foundation
import BitcoinDevKit
import Observation

@MainActor
@Observable
class SendViewModel {
    var balanceTotal: UInt64 = 0
    
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
    
    func send(address: String, amount: UInt64, feeRate: Float?) {
        do {
            try BDKService.shared.send(address: address, amount: amount, feeRate: feeRate)
        } catch let error as WalletError {
            print("getBalance - Wallet Error: \(error.localizedDescription)")
        } catch {
            print("getBalance - Undefined Error: \(error.localizedDescription)")
        }
    }
    
}
