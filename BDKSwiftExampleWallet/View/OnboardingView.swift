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
                    Image(systemName: "bitcoinsign.circle")
                        .resizable()
                        .foregroundStyle(
                            .secondary
                        )
                        .frame(width: 100, height: 100, alignment: .center)
                    Text("powered by Bitcoin Dev Kit")
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(
                                    colors: [
                                        .secondary,
                                        .primary,
                                    ]
                                ),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .fontWidth(.expanded)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding()
                }

                Picker(
                    "Network",
                    selection: $viewModel.selectedNetwork
                ) {
                    Text("Signet").tag(Network.signet)
                    Text("Testnet").tag(Network.testnet)
                    Text("Regtest").tag(Network.regtest)
                }
                .pickerStyle(.automatic)
                .tint(.primary)

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
                .tint(.primary)

                VStack {
                    TextField(
                        "(Optional) Import 12 Word Seed Phrase",
                        text: $viewModel.words
                    )
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
                    } else {
                    }
                }
                .padding(.top, 30)

                Spacer()

                Button("Create Wallet") {
                    viewModel.createWallet()
                }
                .buttonStyle(
                    BitcoinFilled(
                        tintColor: .bitcoinOrange,
                        isCapsule: true
                    )
                )
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
#endif
