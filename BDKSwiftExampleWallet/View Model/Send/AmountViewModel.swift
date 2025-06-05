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

    var amountViewError: AppError?
    var balanceConfirmed: UInt64?
    var balanceTotal: UInt64?
    var showingAmountViewErrorAlert = false

    init(bdkClient: BDKClient = .live) {
        self.bdkClient = bdkClient
    }

    func getBalance() {
        do {
            let balance = try bdkClient.getBalance()
            self.balanceTotal = balance.total.toSat()
            self.balanceConfirmed = balance.confirmed.toSat()
        } catch let error as WalletError {
            self.amountViewError = .generic(message: error.localizedDescription)
            self.showingAmountViewErrorAlert = true
        } catch {
            self.amountViewError = .generic(message: error.localizedDescription)
            self.showingAmountViewErrorAlert = true
        }
    }

}
