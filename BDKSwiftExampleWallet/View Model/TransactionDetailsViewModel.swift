//
//  TransactionDetailsViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 2/15/24.
//

import BitcoinDevKit
import Foundation
//
//class TransactionDetailsViewModel: ObservableObject {
//    let bdkClient: BDKClient
//    let keyClient: KeyClient
//
//    @Published var network: String?
//    @Published var esploraURL: String?
//    @Published var transactionDetailsError: Alpha3Error?//BdkError?
//    @Published var showingTransactionDetailsViewErrorAlert = false
//
//    init(
//        bdkClient: BDKClient = .live,
//        keyClient: KeyClient = .live
//    ) {
//        self.bdkClient = bdkClient
//        self.keyClient = keyClient
//    }
//
//    func getNetwork() {
//        do {
//            self.network = try keyClient.getNetwork()
//        } catch _ as Alpha3Error {//BdkError {
//            DispatchQueue.main.async {
//                self.transactionDetailsError = Alpha3Error.Generic(message: "Could not get network")
//                self.showingTransactionDetailsViewErrorAlert = true
//            }
//        } catch {
//            DispatchQueue.main.async {
//                self.transactionDetailsError = Alpha3Error.Generic(message: "Could not get network")
//                self.showingTransactionDetailsViewErrorAlert = true
//            }
//        }
//    }
//
//    func getEsploraUrl() {
//        do {
//            let savedEsploraURL = try keyClient.getEsploraURL()
//            if network == "Signet" {
//                self.esploraURL = "https://mempool.space/signet"
//            } else {
//                self.esploraURL = savedEsploraURL
//            }
//        } catch _ as Alpha3Error {//BdkError {
//            DispatchQueue.main.async {
//                self.transactionDetailsError = Alpha3Error.Generic(message: "Could not get esplora")
//            }
//        } catch {
//            DispatchQueue.main.async {
//                self.transactionDetailsError = Alpha3Error.Generic(message: "Could not get esplora")
//            }
//        }
//    }
//}
