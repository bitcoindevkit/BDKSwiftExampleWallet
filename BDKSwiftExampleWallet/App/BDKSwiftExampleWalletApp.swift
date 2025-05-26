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
    @State private var navigationPath = NavigationPath()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigationPath) {
                let value = try? KeyClient.live.getBackupInfo()
                if value != nil && !isOnboarding {
                    HomeView(
                        viewModel: .init(
                            bdkClient: .live
                        ),
                        navigationPath: $navigationPath
                    )
                } else {
                    OnboardingView(
                        viewModel: .init(
                            bdkClient: .live
                        )
                    )
                }
            }
            .onChange(of: isOnboarding) { oldValue, newValue in
                BDKClient.live.setNeedsFullScan(true)
                navigationPath = NavigationPath()
            }
        }
    }
}
