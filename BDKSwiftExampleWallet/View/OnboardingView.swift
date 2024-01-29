//
//  OnboardingView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 5/23/23.
//

import BitcoinDevKit
import BitcoinUI
import SwiftUI

struct OnboardingView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @AppStorage("isOnboarding") var isOnboarding: Bool?
    @State private var showingOnboardingViewErrorAlert = false

    var body: some View {

        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack {

                Spacer()

                VStack(spacing: 25) {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .resizable()
                        .foregroundColor(.bitcoinOrange)
                        .frame(width: 100, height: 100, alignment: .center)
                    Text("Bitcoin Wallet")
                        .textStyle(BitcoinTitle1())
                        .multilineTextAlignment(.center)
                        .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
                    Text("A simple bitcoin wallet.")
                        .textStyle(BitcoinBody1())
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                VStack {

                    Text("Choose your Network.")
                        .textStyle(BitcoinBody4())
                        .multilineTextAlignment(.center)

                    VStack {
                        Picker(
                            "Network",
                            selection: $viewModel.selectedNetwork
                        ) {
                            Text("Bitcoin").tag(Network.bitcoin)
                            Text("Testnet").tag(Network.testnet)
                            Text("Signet").tag(Network.signet)
                            Text("Regtest").tag(Network.regtest)
                        }
                        .pickerStyle(.automatic)
                        .tint(viewModel.buttonColor)

                        Picker(
                            "Esplora Server",
                            selection: $viewModel.selectedURL
                        ) {
                            ForEach(viewModel.availableURLs, id: \.self) { url in
                                Text(
                                    url.replacingOccurrences(
                                        of: "https://",
                                        with: ""
                                    ).replacingOccurrences(
                                        of: "http://",
                                        with: ""
                                    )
                                )
                                .tag(url)
                            }
                        }
                        .pickerStyle(.automatic)
                        .tint(viewModel.buttonColor)

                    }

                }
                .padding()

                VStack(spacing: 25) {
                    TextField("12 Word Seed Phrase (Optional)", text: $viewModel.words)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 40)
                    Button("Create Wallet") {
                        viewModel.createWallet()
                    }
                    .buttonStyle(BitcoinFilled(tintColor: .bitcoinOrange, isCapsule: true))
                }
                .padding(.top, 30)

                Spacer()

                VStack {
                    Text("Your wallet, your coins")
                        .textStyle(BitcoinBody4())
                        .multilineTextAlignment(.center)
                    Text("100% open-source & open-design")
                        .textStyle(BitcoinBody4())
                        .multilineTextAlignment(.center)
                }
                .padding(EdgeInsets(top: 32, leading: 32, bottom: 8, trailing: 32))

            }

        }
        .alert(isPresented: $showingOnboardingViewErrorAlert) {
            Alert(
                title: Text("Onboarding Error"),
                message: Text(viewModel.onboardingViewError?.description ?? "Unknown"),
                dismissButton: .default(Text("OK")) {
                    viewModel.onboardingViewError = nil
                }
            )
        }

    }
}

#Preview("OnboardingView - en") {
    OnboardingView(viewModel: .init(bdkClient: .mock))
}

#Preview("OnboardingView - fr") {
    OnboardingView(viewModel: .init(bdkClient: .mock))
        .environment(\.locale, .init(identifier: "fr"))
}
