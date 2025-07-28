//
//  BDKSwiftExampleWalletApp.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 5/22/23.
//

import BitcoinDevKit
import SwiftUI

extension Notification.Name {
    static let walletCreated = Notification.Name("walletCreated")
}

@main
struct BDKSwiftExampleWalletApp: App {
    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    @State private var navigationPath = NavigationPath()
    @State private var refreshTrigger = UUID()
    
    private var walletExists: Bool {
        // Force re-evaluation by reading refreshTrigger and isOnboarding
        let _ = refreshTrigger
        let _ = isOnboarding
        return (try? KeyClient.live.getBackupInfo()) != nil
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigationPath) {
                if !walletExists {
                    OnboardingView(viewModel: .init(bdkClient: .live))
                        .onReceive(NotificationCenter.default.publisher(for: .walletCreated)) { _ in
                            refreshTrigger = UUID()
                        }
                } else {
                    HomeView(viewModel: .init(bdkClient: .live), navigationPath: $navigationPath)
                }
            }
            .onChange(of: isOnboarding) { oldValue, newValue in
                BDKClient.live.setNeedsFullScan(true)
                navigationPath = NavigationPath()
            }
        }
    }
}
