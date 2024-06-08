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

    var psbt: Psbt?
    var buildTransactionViewError: AppError?
    var showingBuildTransactionViewErrorAlert = false
    var calculateFee: String?

    init(
        bdkClient: BDKClient = .live
    ) {
        self.bdkClient = bdkClient
    }

    func buildTransaction(address: String, amount: UInt64, feeRate: UInt64) {
        do {
            let txBuilderResult = try bdkClient.buildTransaction(address, amount, feeRate)
            self.psbt = txBuilderResult
        } catch let error as WalletError {
            self.buildTransactionViewError = .generic(message: error.localizedDescription)
            self.showingBuildTransactionViewErrorAlert = true
        } catch {
            self.buildTransactionViewError = .generic(message: error.localizedDescription)
            self.showingBuildTransactionViewErrorAlert = true
        }
    }

    func send(address: String, amount: UInt64, feeRate: UInt64) {
        do {
            try bdkClient.send(address, amount, feeRate)
            NotificationCenter.default.post(
                name: Notification.Name("TransactionSent"),
                object: nil
            )
        } catch let error as EsploraError {
            self.buildTransactionViewError = .generic(message: error.localizedDescription)
            self.showingBuildTransactionViewErrorAlert = true
        } catch let error as SignerError {
            self.buildTransactionViewError = .generic(message: error.localizedDescription)
            self.showingBuildTransactionViewErrorAlert = true
        } catch let error as WalletError {
            self.buildTransactionViewError = .generic(message: error.localizedDescription)
            self.showingBuildTransactionViewErrorAlert = true
        } catch {
            self.buildTransactionViewError = .generic(message: error.localizedDescription)
            self.showingBuildTransactionViewErrorAlert = true
        }
    }

    func getCalulateFee(tx: BitcoinDevKit.Transaction) {
        do {
            let calculateFee = try bdkClient.calculateFee(tx)
            let feeString = String(calculateFee)
            self.calculateFee = feeString
        } catch let error as CalculateFeeError {
            self.buildTransactionViewError = .generic(message: error.localizedDescription)
        } catch {
            self.buildTransactionViewError = .generic(message: error.localizedDescription)
        }
    }

    func extractTransaction() -> BitcoinDevKit.Transaction? {
        guard let psbt = self.psbt else {
            self.buildTransactionViewError = .generic(message: "PSBT is nil.")
            self.showingBuildTransactionViewErrorAlert = true
            return nil
        }
        do {
            let transaction = try psbt.extractTx()
            return transaction
        } catch let error {
            self.buildTransactionViewError = .generic(
                message: "Failed to extract transaction: \(error.localizedDescription)"
            )
            self.showingBuildTransactionViewErrorAlert = true
            return nil
        }
    }

}
