//
//  TransactionListViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 4/3/24.
//

import BitcoinDevKit
import Foundation

@MainActor
@Observable
class TransactionListViewModel {
    let bdkClient: BDKClient
    var walletTransactionsViewError: AppError?
    var showingWalletTransactionsViewErrorAlert = false

    init(
        bdkClient: BDKClient = .live
    ) {
        self.bdkClient = bdkClient
    }

    func getSentAndReceived(tx: BitcoinDevKit.Transaction) -> SentAndReceivedValues? {
        do {
            let sentAndReceived = try bdkClient.sentAndReceived(tx)
            return sentAndReceived
        } catch {
            self.walletTransactionsViewError = .generic(
                message: error.localizedDescription
            )
            self.showingWalletTransactionsViewErrorAlert = true
            return nil
        }
    }

}
