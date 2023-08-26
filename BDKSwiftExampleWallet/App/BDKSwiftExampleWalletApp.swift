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
    let bdkService: BDKServiceAPI = .mock

    init() {
        do {
            try bdkService.loadWallet()//BDKService.shared.loadWalletFromBackup()
            // TODO: remove after testing
            // try bdkService.deleteWallet()// try BDKService.shared.deleteWallet()
        } catch {
            print("BDKSwiftExampleWalletApp error: \(error.localizedDescription)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if isOnboarding {
                OnboardingView(viewModel: .init(bdkService: .mock))
            } else {
                TabHomeView()
            }
        }
    }
    
}
