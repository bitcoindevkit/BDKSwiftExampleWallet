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
                    Text("BDK Wallet")
                        .textStyle(BitcoinTitle1())
                        .multilineTextAlignment(.center)
                        .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
                    Text("A bitcoin wallet powered by Bitcoin Dev Kit")
                        .textStyle(BitcoinBody5())
                        .fontWidth(.expanded)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                VStack {

                    VStack {
                        Picker(
                            "Network",
                            selection: $viewModel.selectedNetwork
                        ) {
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

                VStack {
                    TextField("12 Word Seed Phrase (Optional)", text: $viewModel.words)
                        .submitLabel(.done)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 40)
                    if viewModel.wordArray != [] {
                        SeedPhraseView(
                            words: viewModel.wordArray,
                            preferredWordsPerRow: 2,
                            usePaging: true,
                            wordsPerPage: 4
                        )
                        .frame(height: 200)
                    }
                }
                .padding(.top, 30)

                Spacer()

                Button("Create Wallet") {
                    viewModel.createWallet()
                }
                .buttonStyle(BitcoinFilled(tintColor: .bitcoinOrange, isCapsule: true))
                .padding()

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

#if DEBUG
    #Preview("OnboardingView - en") {
        OnboardingView(viewModel: .init(bdkClient: .mock))
    }
    #Preview("OnboardingView - en - Large") {
        OnboardingView(viewModel: .init(bdkClient: .mock))
            .environment(\.dynamicTypeSize, .accessibility5)
    }
    #Preview("OnboardingView - fr") {
        OnboardingView(viewModel: .init(bdkClient: .mock))
            .environment(\.locale, .init(identifier: "fr"))
    }
#endif
