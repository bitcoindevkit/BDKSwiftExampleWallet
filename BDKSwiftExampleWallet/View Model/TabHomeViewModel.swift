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

    var tabViewError: Alpha3Error?
    var showingTabViewErrorAlert = false

    init(bdkClient: BDKClient = .live) {
        self.bdkClient = bdkClient
    }

    func loadWallet() {
        do {
            try bdkClient.loadWallet()
        } catch let error as WalletError {
            self.tabViewError = .Generic(message: error.localizedDescription)
            self.showingTabViewErrorAlert = true
        } catch let error as Alpha3Error {
            self.tabViewError = .Generic(message: error.description)
            self.showingTabViewErrorAlert = true
        } catch {
            self.tabViewError = .Generic(message: "Error Getting Balance")
            self.showingTabViewErrorAlert = true
        }
    }

}
