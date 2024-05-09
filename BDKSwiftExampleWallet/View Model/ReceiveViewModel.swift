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
    var receiveViewError: AppError?
    var showingReceiveViewErrorAlert = false

    init(bdkClient: BDKClient = .live) {
        self.bdkClient = bdkClient
    }

    func getAddress() {
        do {
            let address = try bdkClient.getAddress()
            self.address = address
        } catch let error as WalletError {
            self.receiveViewError = .generic(message: error.localizedDescription)
            self.showingReceiveViewErrorAlert = true
        } catch {
            self.receiveViewError = .generic(message: error.localizedDescription)
            self.showingReceiveViewErrorAlert = true
        }
    }

}
