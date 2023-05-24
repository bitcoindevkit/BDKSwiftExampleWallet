//
//  OnboardingView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 5/23/23.
//

import SwiftUI
import WalletUI

class OnboardingViewModel: ObservableObject {}

struct OnboardingView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()
                
                VStack {
                    Text("Onboarding")
                    NavigationLink {
                        WalletView(viewModel: .init())
                    } label: {
                        Text("Create Wallet")
                            .foregroundColor(Color(uiColor: .systemBackground))
                    }
                    .buttonStyle(BitcoinFilled(tintColor: .bitcoinOrange))
                }
                .padding()
                
            }
            
        }
        
    }
    
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(viewModel: .init())
            .previewDisplayName("Light Mode")
        OnboardingView(viewModel: .init())
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Dark Mode")
    }
}
