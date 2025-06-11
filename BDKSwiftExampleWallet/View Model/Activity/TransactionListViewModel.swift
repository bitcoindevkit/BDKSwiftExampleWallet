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

    var showingWalletTransactionsViewErrorAlert = false
    var walletTransactionsViewError: AppError?

    init(
        bdkClient: BDKClient = .live
    ) {
        self.bdkClient = bdkClient
    }

    func getTxDetails(txid: Txid) -> TxDetails? {
        do {
            let txDetails = try bdkClient.txDetails(txid)
            return txDetails
        } catch {
            self.walletTransactionsViewError = .generic(
                message: error.localizedDescription
            )
            self.showingWalletTransactionsViewErrorAlert = true
            return nil
        }
    }

    func getEsploraURL() -> String {
        let savedEsploraURL = bdkClient.getEsploraURL()
        return savedEsploraURL
    }

    func getNetwork() -> String {
        let savedNetwork = bdkClient.getNetwork().description
        return savedNetwork
    }

}
