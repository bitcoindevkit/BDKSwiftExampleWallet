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
                let keyClient = KeyClient.live
                let syncService: BDKSyncService = EsploraServerSyncService(
                    keyClient: keyClient,
                    network: .signet
                )
                if let _ = try? KeyClient.live.getBackupInfo() {
                    HomeView(
                        viewModel: .init(
                            bdkClient: .live,
                            bdkSyncService: syncService
                        ),
                        navigationPath: $navigationPath
                    )
                } else {
                    OnboardingView(
                        viewModel: .init(
                            bdkSyncService: syncService
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
