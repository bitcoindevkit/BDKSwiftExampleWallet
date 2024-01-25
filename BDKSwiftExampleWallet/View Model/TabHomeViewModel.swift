//
//  TabHomeViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 1/24/24.
//

import Foundation

class TabHomeViewModel: ObservableObject {
    let bdkClient: BDKClient

    init(bdkClient: BDKClient = .live) {
        self.bdkClient = bdkClient
    }

    func loadWallet() {
        do {
            try bdkClient.loadWallet()
        } catch {
            print("loadWallet - Wallet Error: \(error.localizedDescription)")
        }
    }

}
