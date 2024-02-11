//
//  ReceiveViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/6/23.
//

import Foundation
import Observation

@Observable
class ReceiveViewModel {
    let bdkClient: BDKClient

    var address: String = "" {
        didSet {
            address = address.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    init(bdkClient: BDKClient = .live) {
        self.bdkClient = bdkClient
    }

    func getAddress() {
        do {
            let address = try bdkClient.getAddress()
            self.address = address
        } catch {
            self.address = "Error getting address."
        }
    }

}
