//
//  ReceiveViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/6/23.
//

import BitcoinDevKit
import Foundation
import Observation

@Observable
class ReceiveViewModel {
    let bdkClient: BDKClient

    var address: String = ""
    var receiveViewError: Alpha3Error?//BdkError?
    var showingReceiveViewErrorAlert = false

    init(bdkClient: BDKClient = .live) {
        self.bdkClient = bdkClient
    }

    func getAddress() {
        do {
            let address = try bdkClient.getAddress()
            self.address = address
        } catch let error as WalletError {
            self.receiveViewError = .Generic(message: error.localizedDescription)
            self.showingReceiveViewErrorAlert = true
        } catch let error as Alpha3Error {
            self.receiveViewError = .Generic(message: error.description)
            self.showingReceiveViewErrorAlert = true
        } catch {
            self.receiveViewError = .Generic(message: "Error Getting Address")
            self.showingReceiveViewErrorAlert = true
        }
    }

}
