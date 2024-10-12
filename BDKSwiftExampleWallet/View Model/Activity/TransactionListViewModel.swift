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
    let keyClient: KeyClient

    var showingWalletTransactionsViewErrorAlert = false
    var walletTransactionsViewError: AppError?

    init(
        bdkClient: BDKClient = .live,
        keyClient: KeyClient = .live
    ) {
        self.bdkClient = bdkClient
        self.keyClient = keyClient
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

    func getEsploraURL() -> String? {
        let savedEsploraURL = try? keyClient.getEsploraURL()
        return savedEsploraURL
    }

}
