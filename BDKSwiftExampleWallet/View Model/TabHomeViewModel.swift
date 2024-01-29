//
//  TabHomeViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 1/24/24.
//

import BitcoinDevKit
import Foundation

class TabHomeViewModel: ObservableObject {
    let bdkClient: BDKClient
    @Published var tabViewError: BdkError?

    init(bdkClient: BDKClient = .live) {
        self.bdkClient = bdkClient
    }

    func loadWallet() {
        do {
            try bdkClient.loadWallet()
        } catch {
            DispatchQueue.main.async {
                self.tabViewError = .InvalidNetwork(message: "Wallet Loading Error")
            }
        }
    }

}
