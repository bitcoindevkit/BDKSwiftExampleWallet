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
    let keyClient: KeyClient

    var calculateFee: String?
    var calculateFeeError: CalculateFeeError?
    var esploraError: EsploraError?
    var esploraURL: String?
    var network: String?
    var showingTransactionDetailsViewErrorAlert = false
    var transactionDetailsError: AppError?

    init(
        bdkClient: BDKClient = .live,
        keyClient: KeyClient = .live
    ) {
        self.bdkClient = bdkClient
        self.keyClient = keyClient
    }

    func getCalulateFee(tx: BitcoinDevKit.Transaction) {
        do {
            let calculateFee = try bdkClient.calculateFee(tx)
            let feeString = String(calculateFee.toSat())
            self.calculateFee = feeString
        } catch let error as CalculateFeeError {
            DispatchQueue.main.async {
                self.calculateFeeError = error
            }
        } catch {}
    }

    func getEsploraUrl() {
        do {
            let savedEsploraURL = try keyClient.getEsploraURL()
            if network == "Signet" {
                self.esploraURL = "https://mempool.space/signet"
            } else {
                self.esploraURL = savedEsploraURL
            }
        } catch let error as EsploraError {
            DispatchQueue.main.async {
                self.esploraError = error
            }
        } catch {}
    }

    func getNetwork() {
        do {
            self.network = try keyClient.getNetwork()
        } catch {
            DispatchQueue.main.async {
                self.transactionDetailsError = .generic(message: error.localizedDescription)
            }
        }
    }

    func getSentAndReceived(tx: BitcoinDevKit.Transaction) -> SentAndReceivedValues? {
        do {
            let sentAndReceived = try bdkClient.sentAndReceived(tx)
            return sentAndReceived
        } catch {
            DispatchQueue.main.async {
                self.transactionDetailsError = .generic(message: error.localizedDescription)
            }
            return nil
        }
    }

}
