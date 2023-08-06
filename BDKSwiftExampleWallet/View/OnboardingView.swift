//
//  OnboardingView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 5/23/23.
//

import SwiftUI
import WalletUI
import BitcoinDevKit

class OnboardingViewModel: ObservableObject {
    @AppStorage("isOnboarding") var isOnboarding: Bool?

    func createWallet() {
        do {
            try BDKService.shared.createWallet()
//            self.balanceTotal = balance.total
            isOnboarding = false
        } catch let error as WalletError {
            print("getBalance - Wallet Error: \(error.localizedDescription)")
        } catch {
            print("getBalance - Undefined Error: \(error.localizedDescription)")
        }
    }
    
    func restoreWallet() {
        do {
            let backupInfo = try KeyService().getBackupInfo()
            let descriptor = try Descriptor(descriptor: backupInfo.descriptor, network: BDKService.shared.network)
            let changeDescriptor = try Descriptor(descriptor: backupInfo.changeDescriptor, network: BDKService.shared.network)
            try BDKService.shared.loadWallet(descriptor: descriptor, changeDescriptor: changeDescriptor)
            isOnboarding = false
        } catch {
            print("BDKSwiftExampleWalletApp backupInfo error: \(error.localizedDescription)")
        }
    }
    
}

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
                        
                        Text("A simple bitcoin wallet for your enjoyment.")
                            .textStyle(BitcoinBody1())
                            .opacity(0.4)
                            .multilineTextAlignment(.center)
                    }
                    
                    VStack(spacing: 25){
                        
                        Button("Create a new wallet") {
                            viewModel.createWallet()//BDKService.shared.createWallet()
//                            isOnboarding = false
                        }
                        .buttonStyle(BitcoinFilled(tintColor: .bitcoinOrange))

                        Button("Restore Wallet from Keychain") {
//                            do {
//                                let backupInfo = try KeyService().getBackupInfo()
//                                let descriptor = try Descriptor(descriptor: backupInfo.descriptor, network: BDKService.shared.network)
//                                let changeDescriptor = try Descriptor(descriptor: backupInfo.changeDescriptor, network: BDKService.shared.network)
//                                BDKService.shared.loadWallet(descriptor: descriptor, changeDescriptor: changeDescriptor)
//                                isOnboarding = false
//                            } catch {
//                                print("BDKSwiftExampleWalletApp backupInfo error: \(error.localizedDescription)")
//                            }
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
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(viewModel: .init())
            .previewDisplayName("Light Mode")
        OnboardingView(viewModel: .init())
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Dark Mode")
    }
}
