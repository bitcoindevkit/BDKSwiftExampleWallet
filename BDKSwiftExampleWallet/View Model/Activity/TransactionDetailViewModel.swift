//
//  TransactionDetailViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 2/15/24.
//

import BitcoinDevKit
import Foundation
import Observation

@MainActor
@Observable
class TransactionDetailViewModel {
    let bdkClient: BDKClient

    var esploraError: EsploraError?
    var esploraURL: String?
    var network: String?
    var showingTransactionDetailsViewErrorAlert = false
    var transactionDetailsError: AppError?

    init(
        bdkClient: BDKClient = .live
    ) {
        self.bdkClient = bdkClient
    }

    func getEsploraUrl() {
        let savedEsploraURL = bdkClient.getEsploraURL()

        switch network {
        case "signet":
            if savedEsploraURL == Constants.Config.EsploraServerURLNetwork.Signet.bdk {
                self.esploraURL = "https://mempool.space/signet"
            } else {
                self.esploraURL = "https://mutinynet.com"
            }
        case "testnet":
            if savedEsploraURL == Constants.Config.EsploraServerURLNetwork.Testnet.blockstream {
                self.esploraURL = "https://blockstream.info/testnet"
            } else {
                self.esploraURL = "https://mempool.space/testnet"
            }
        default:
            self.esploraURL = savedEsploraURL
        }
    }

    func getNetwork() {
        self.network = bdkClient.getNetwork().description
    }

}
