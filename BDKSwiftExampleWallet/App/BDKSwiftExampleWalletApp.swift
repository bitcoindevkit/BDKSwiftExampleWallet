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
    @State private var isOnboardingPresented = false // Add this state variable to track if the onboarding view is presented

    init() {
        do {
            let keyData = try KeyService().getKeyData()
            let descriptor = try Descriptor(descriptor: keyData.descriptor, network: BDKService.shared.network)
            let changeDescriptor = try Descriptor(descriptor: keyData.changeDescriptor, network: BDKService.shared.network)
            BDKService.shared.loadWallet(descriptor: descriptor, changeDescriptor: changeDescriptor)
//            self.isOnboardingPresented = false
        } catch {
            print("BDKSwiftExampleWalletApp getKeyData error: \(error.localizedDescription)")
        }
    }
    
    
    var body: some Scene {
        
        WindowGroup {
            
            // if something in wallet go to TabView/WalletView
            if BDKService.shared.wallet != nil {
                TabHomeView()
//                    .fullScreenCover(
//                        isPresented: $isOnboardingPresented,
//                        onDismiss: { /*isOnboardingPresented = false */ }
//                    ) {
//                        OnboardingView(viewModel: .init())
//                    }
            } else {
                 //else go to OnboardingView
                OnboardingView(viewModel: .init())
                    .fullScreenCover(
                        isPresented: $isOnboardingPresented,
                        onDismiss: { isOnboardingPresented = false }
                    ) {
                        TabHomeView()
                    }
            }
 
        }
    }
}
