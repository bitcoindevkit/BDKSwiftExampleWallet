//
//  SettingsViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 1/24/24.
//

import BitcoinDevKit
import Foundation
import SwiftUI

class SettingsViewModel: ObservableObject {
    let bdkClient: BDKClient
    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    @Published var settingsError: BdkError?

    init(bdkClient: BDKClient = .live) {
        self.bdkClient = bdkClient
    }

    func delete() {
        do {
            try bdkClient.deleteWallet()
            self.isOnboarding = true
        } catch _ as BdkError {
            DispatchQueue.main.async {
                self.settingsError = BdkError.Generic(message: "Could not delete seed")
            }
        } catch {
            DispatchQueue.main.async {
                self.settingsError = BdkError.Generic(message: "Could not delete seed")
            }
        }
    }
}
