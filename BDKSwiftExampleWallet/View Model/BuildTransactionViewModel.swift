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
    var txBuilderResult: TxBuilderResult?

    init(
        bdkClient: BDKClient = .live
    ) {
        self.bdkClient = bdkClient
    }

    func buildTransaction(address: String, amount: UInt64, feeRate: Float?) {
        do {
            let txBuilderResult = try bdkClient.buildTransaction(address, amount, feeRate)
            self.txBuilderResult = txBuilderResult
        } catch let error as WalletError {
            print("buildTransaction - Send Error: \(error.localizedDescription)")
        } catch let error as BdkError {
            print("buildTransaction - BDK Error: \(error.description)")
        } catch {
            print("buildTransaction - Undefined Error: \(error.localizedDescription)")
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
            print("send - Send Error: \(error.localizedDescription)")
        } catch let error as BdkError {
            print("send - BDK Error: \(error.description)")
        } catch {
            print("send - Undefined Error: \(error.localizedDescription)")
        }
    }

}
