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

    var tabViewError: AppError?
    var showingTabViewErrorAlert = false

    init(bdkClient: BDKClient = .live) {
        self.bdkClient = bdkClient
    }

    func loadWallet() {
        do {
            try bdkClient.loadWallet()
        } catch let error as DescriptorError {
            self.tabViewError = .generic(message: error.localizedDescription)
            self.showingTabViewErrorAlert = true
        } catch let error as WalletCreationError {
            self.tabViewError = .generic(message: error.localizedDescription)
            self.showingTabViewErrorAlert = true
        } catch {
            self.tabViewError = .generic(message: error.localizedDescription)
            self.showingTabViewErrorAlert = true
        }
    }

}
