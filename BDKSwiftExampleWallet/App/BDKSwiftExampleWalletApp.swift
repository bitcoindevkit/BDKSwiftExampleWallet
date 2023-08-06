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
            let backupInfo = try KeyService().getBackupInfo()
            let descriptor = try Descriptor(descriptor: backupInfo.descriptor, network: BDKService.shared.network)
            let changeDescriptor = try Descriptor(descriptor: backupInfo.changeDescriptor, network: BDKService.shared.network)
            try BDKService.shared.loadWallet(descriptor: descriptor, changeDescriptor: changeDescriptor)
        }
        catch {
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
