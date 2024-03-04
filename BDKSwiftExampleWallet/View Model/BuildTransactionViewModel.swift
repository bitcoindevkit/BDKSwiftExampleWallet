//
//  BuildTransactionViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 9/23/23.
//

import BitcoinDevKit
import Foundation

@MainActor
@Observable
class BuildTransactionViewModel {
    let bdkClient: BDKClient

    var psbt: PartiallySignedTransaction?
    var buildTransactionViewError: Alpha3Error?
    var showingBuildTransactionViewErrorAlert = false
    var calculateFee: String?

    init(
        bdkClient: BDKClient = .live
    ) {
        self.bdkClient = bdkClient
    }

    func buildTransaction(address: String, amount: UInt64, feeRate: Float?) {
        do {
            let txBuilderResult = try bdkClient.buildTransaction(address, amount, feeRate)
            self.psbt = txBuilderResult
        } catch let error as WalletError {
            self.buildTransactionViewError = .Generic(message: error.localizedDescription)
            self.showingBuildTransactionViewErrorAlert = true
        } catch let error as Alpha3Error {
            self.buildTransactionViewError = .Generic(message: error.description)
            self.showingBuildTransactionViewErrorAlert = true
        } catch {
            self.buildTransactionViewError = .Generic(message: "Error Building Transaction")
            self.showingBuildTransactionViewErrorAlert = true
        }
    }

    func send(address: String, amount: UInt64, feeRate: Float?) {
        do {
            try bdkClient.send(address, amount, feeRate)
            NotificationCenter.default.post(
                name: Notification.Name("TransactionSent"),
                object: nil
            )
        } catch let error as WalletError {
            self.buildTransactionViewError = .Generic(message: error.localizedDescription)
            self.showingBuildTransactionViewErrorAlert = true
        } catch let error as Alpha3Error {
            self.buildTransactionViewError = .Generic(message: error.description)
            self.showingBuildTransactionViewErrorAlert = true
        } catch {
            self.buildTransactionViewError = .Generic(message: "Error Sending")
            self.showingBuildTransactionViewErrorAlert = true
        }
    }

    func getCalulateFee(tx: BitcoinDevKit.Transaction) {
        do {
            let calculateFee = try bdkClient.calculateFee(tx)
            let feeString = String(calculateFee)
            self.calculateFee = feeString
        } catch _ as Alpha3Error {
            DispatchQueue.main.async {
                self.buildTransactionViewError = Alpha3Error.Generic(
                    message: "Could not get esplora"
                )
            }
        } catch {
            DispatchQueue.main.async {
                self.buildTransactionViewError = Alpha3Error.Generic(
                    message: "Could not get esplora"
                )
            }
        }

    }

}
