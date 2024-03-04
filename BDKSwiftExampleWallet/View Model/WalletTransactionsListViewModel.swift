//
//  WalletTransactionsListViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 4/3/24.
//

import BitcoinDevKit
import Foundation

@MainActor
@Observable
class WalletTransactionsListViewModel {
    let bdkClient: BDKClient
    var walletTransactionsViewError: Alpha3Error?
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
        } catch let error as Alpha3Error {
            self.walletTransactionsViewError = error
            self.showingWalletTransactionsViewErrorAlert = true
            return nil
        } catch {
            self.walletTransactionsViewError = Alpha3Error.Generic(
                message: error.localizedDescription
            )
            self.showingWalletTransactionsViewErrorAlert = true
            return nil
        }
    }

}
