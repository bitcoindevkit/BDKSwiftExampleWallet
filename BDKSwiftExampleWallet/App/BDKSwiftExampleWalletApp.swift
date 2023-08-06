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

    init() {
        do {
            try BDKService.shared.loadWalletFromBackup()
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
