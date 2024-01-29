//
//  TabHomeViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 1/24/24.
//

import BitcoinDevKit
import Foundation

@MainActor
@Observable
class TabHomeViewModel: ObservableObject {
    let bdkClient: BDKClient
    var tabViewError: BdkError?

    init(bdkClient: BDKClient = .live) {
        self.bdkClient = bdkClient
    }

    func loadWallet() {
        do {
            try bdkClient.loadWallet()
        } catch {
            self.tabViewError = .InvalidNetwork(message: "Wallet Loading Error")
        }
    }

}
