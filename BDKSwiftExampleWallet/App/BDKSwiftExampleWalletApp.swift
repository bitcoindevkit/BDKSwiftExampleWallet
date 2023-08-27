//
//  BDKSwiftExampleWalletApp.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 5/22/23.
//

import SwiftUI
import BitcoinDevKit

@main
struct BDKSwiftExampleWalletApp: App {
    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    let bdkService: BDKClient = .live

    init() {
        do {
            try bdkService.loadWallet()
            // TODO: remove after testing
            // try bdkService.deleteWallet()
        } catch {
            print("BDKSwiftExampleWalletApp error: \(error.localizedDescription)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if isOnboarding {
                OnboardingView(viewModel: .init())
            } else {
                TabHomeView()
            }
        }
    }
    
}
