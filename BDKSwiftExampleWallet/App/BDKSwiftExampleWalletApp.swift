//
//  BDKSwiftExampleWalletApp.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 5/22/23.
//

import BitcoinDevKit
import SwiftUI

@main
struct BDKSwiftExampleWalletApp: App {
    @AppStorage("isOnboarding") var isOnboarding: Bool = true

    var body: some Scene {
        WindowGroup {
            if isOnboarding {
                OnboardingView(viewModel: .init(bdkClient: .live))
            } else {
                TabHomeView(viewModel: .init(bdkClient: .live))
            }
        }
    }

}
