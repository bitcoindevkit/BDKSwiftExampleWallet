//
//  OnboardingView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 5/23/23.
//

import SwiftUI
import WalletUI

struct OnboardingView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @AppStorage("isOnboarding") var isOnboarding: Bool?
    
    var body: some View {
        
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
            
            VStack {
                
                Spacer()
                
                VStack(spacing: 25) {
                    
                    Image(systemName:"bitcoinsign.circle.fill")
                        .resizable()
                        .foregroundColor(.bitcoinOrange)
                        .frame(width: 100, height: 100, alignment: .center)
                    
                    Text("Bitcoin wallet")
                        .textStyle(BitcoinTitle1())
                        .multilineTextAlignment(.center)
                        .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
                    
                    Text("A simple bitcoin wallet for your enjoyment.")
                        .textStyle(BitcoinBody1())
                        .opacity(0.4)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 25){
                    
                    Button("Create a new wallet") {
                        viewModel.createWallet()
                    }
                    .buttonStyle(BitcoinFilled(tintColor: .bitcoinOrange))
                    .minimumScaleFactor(0.9)
                    
                    Button("Restore Wallet from Keychain") {
                        viewModel.restoreWallet()
                    }
                    .buttonStyle(BitcoinFilled(tintColor: .bitcoinOrange))
                    
                }
                .padding(.top, 30)
                
                Spacer()
                
                VStack {
                    Text("Your wallet, your coins \n 100% open-source & open-design")
                        .textStyle(BitcoinBody4())
                        .multilineTextAlignment(.center)
                }
                .padding(EdgeInsets(top: 32, leading: 32, bottom: 8, trailing: 32))
                
            }
        }
        
    }    
}

#Preview {
    OnboardingView(viewModel: .init())
}
