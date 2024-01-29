//
//  AmountViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 9/22/23.
//

import BitcoinDevKit
import Foundation

@MainActor
@Observable
class AmountViewModel {
    let bdkClient: BDKClient

    var balanceTotal: UInt64?
    var balanceConfirmed: UInt64?
    var amountViewError: BdkError?

    init(bdkClient: BDKClient = .live) {
        self.bdkClient = bdkClient
    }

    func getBalance() {
        do {
            let balance = try bdkClient.getBalance()
            self.balanceTotal = balance.total
            self.balanceConfirmed = balance.confirmed
        } catch let error as WalletError {
            self.amountViewError = .Generic(message: error.localizedDescription)
        } catch {
            self.amountViewError = .Generic(message: "Error Getting Balance")
        }
    }

}
