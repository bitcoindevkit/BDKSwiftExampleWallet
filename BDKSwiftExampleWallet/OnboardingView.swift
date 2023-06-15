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
                    
                    Spacer()
                    
                    VStack(spacing: 25) {
                        
                        Image(systemName:"bitcoinsign.circle.fill")
                            .resizable()
                            .foregroundColor(.bitcoinOrange)
                            .frame(width: 100, height: 100, alignment: .center)
                        
                        Text("Bitcoin wallet")
                            .textStyle(BitcoinTitle1())
                            .multilineTextAlignment(.center)
                        
                        Text("A simple bitcoin wallet for your enjoyment.")
                            .textStyle(BitcoinBody1())
                            .opacity(0.4)
                            .multilineTextAlignment(.center)
                    }
                    
                    VStack(spacing: 25){
                        
                        NavigationLink {
                            TabHomeView()
                        } label: {
                            Text("Create a new wallet")
                                .foregroundColor(Color.white)
                                .textStyle(BitcoinBody1())
                        }
                        .buttonStyle(BitcoinFilled(tintColor: .bitcoinOrange))
                        
                        NavigationLink {
                            
                        } label: {
                            Text("Restore existing wallet")
                                .foregroundColor(Color.orange)
                                .textStyle(BitcoinBody1())
                        }
                        .disabled(true)
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
