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

    var buildTransactionViewError: AppError?
    var calculateFee: String?
    var psbt: Psbt?
    var showingBuildTransactionViewErrorAlert = false

    init(
        bdkClient: BDKClient = .live
    ) {
        self.bdkClient = bdkClient
    }

    func buildTransaction(address: String, amount: UInt64, feeRate: UInt64) {
        print("[BuildTransactionViewModel.buildTransaction] Called with:")
        print("  - Address: \(address)")
        print("  - Amount: \(amount) sats")
        print("  - FeeRate: \(feeRate) sat/vB")
        
        do {
            let txBuilderResult = try bdkClient.buildTransaction(address, amount, feeRate)
            self.psbt = txBuilderResult
            print("[BuildTransactionViewModel.buildTransaction] PSBT created successfully")
        } catch let error as WalletError {
            print("[BuildTransactionViewModel.buildTransaction] WalletError: \(error.localizedDescription)")
            self.buildTransactionViewError = .generic(message: error.localizedDescription)
            self.showingBuildTransactionViewErrorAlert = true
        } catch let error as AddressParseError {
            print("[BuildTransactionViewModel.buildTransaction] AddressParseError: \(error.localizedDescription)")
            self.buildTransactionViewError = .generic(message: error.localizedDescription)
            self.showingBuildTransactionViewErrorAlert = true
        } catch {
            print("[BuildTransactionViewModel.buildTransaction] Unknown error: \(error.localizedDescription)")
            print("[BuildTransactionViewModel.buildTransaction] Error type: \(type(of: error))")
            self.buildTransactionViewError = .generic(message: error.localizedDescription)
            self.showingBuildTransactionViewErrorAlert = true
        }
    }

    func extractTransaction() -> BitcoinDevKit.Transaction? {
        guard let psbt = self.psbt else {
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

    func getCalulateFee(tx: BitcoinDevKit.Transaction) {
        do {
            let calculateFee = try bdkClient.calculateFee(tx)
            let feeString = String(calculateFee.toSat())
            self.calculateFee = feeString
        } catch let error as CalculateFeeError {
            self.buildTransactionViewError = .generic(message: error.localizedDescription)
        } catch {
            self.buildTransactionViewError = .generic(message: error.localizedDescription)
        }
    }

    func send(address: String, amount: UInt64, feeRate: UInt64) {
        print("[BuildTransactionViewModel.send] Called with:")
        print("  - Address: \(address)")
        print("  - Amount: \(amount) sats")
        print("  - FeeRate: \(feeRate) sat/vB")
        
        do {
            try bdkClient.send(address, amount, feeRate)
            print("[BuildTransactionViewModel.send] Transaction sent successfully!")
            NotificationCenter.default.post(
                name: Notification.Name("TransactionSent"),
                object: nil
            )
        } catch let error as EsploraError {
            print("[BuildTransactionViewModel.send] EsploraError: \(error.localizedDescription)")
            self.buildTransactionViewError = .generic(message: error.localizedDescription)
            self.showingBuildTransactionViewErrorAlert = true
        } catch let error as SignerError {
            print("[BuildTransactionViewModel.send] SignerError: \(error.localizedDescription)")
            self.buildTransactionViewError = .generic(message: error.localizedDescription)
            self.showingBuildTransactionViewErrorAlert = true
        } catch let error as WalletError {
            print("[BuildTransactionViewModel.send] WalletError: \(error.localizedDescription)")
            self.buildTransactionViewError = .generic(message: error.localizedDescription)
            self.showingBuildTransactionViewErrorAlert = true
        } catch {
            print("[BuildTransactionViewModel.send] Unknown error: \(error.localizedDescription)")
            print("[BuildTransactionViewModel.send] Error type: \(type(of: error))")
            self.buildTransactionViewError = .generic(message: error.localizedDescription)
            self.showingBuildTransactionViewErrorAlert = true
        }
    }

}
