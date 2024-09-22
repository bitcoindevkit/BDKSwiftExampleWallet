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
    @State private var showingImportView = false

    var body: some View {

        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack {

                HStack {
                    Spacer()
                    Button {
                        showingImportView = true
                    } label: {
                        Image(
                            systemName: viewModel.wordArray.isEmpty
                                ? "square.and.arrow.down" : "square.and.arrow.down.fill"
                        )
                    }
                    .tint(
                        viewModel.wordArray.isEmpty ? .secondary : .primary
                    )
                    .font(.title)
                    .padding()
                    .sheet(isPresented: $showingImportView) {
                        ImportView(
                            isPresented: $showingImportView,
                            importedWords: $viewModel.words
                        )
                        .presentationDetents([.medium])
                    }
                }

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
                .padding()

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

                if viewModel.wordArray != [] {
                    SeedPhraseView(
                        words: viewModel.wordArray,
                        preferredWordsPerRow: 2,
                        usePaging: true,
                        wordsPerPage: 4
                    )
                    .frame(height: 200)
                    .padding()
                }

                Spacer()

                Button("Create Wallet") {
                    viewModel.createWallet()
                }
                .buttonStyle(
                    BitcoinFilled(
                        tintColor: .bitcoinOrange,
                        textColor: Color(uiColor: .systemBackground),
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

struct ImportView: View {
    @Binding var isPresented: Bool
    @Binding var importedWords: String

    private var wordArray: [String] {
        importedWords.split(separator: " ").map(String.init)
    }

    var body: some View {

        VStack {

            Spacer()

            TextField("12 Word Seed Phrase", text: $importedWords)
                .submitLabel(.done)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 40)

            if !importedWords.isEmpty {
                SeedPhraseView(
                    words: wordArray,
                    preferredWordsPerRow: 2,
                    usePaging: true,
                    wordsPerPage: 4
                )
                .frame(height: 200)
            }

            Spacer()

            Button("Import") {
                isPresented = false
            }
            .buttonStyle(
                BitcoinFilled(
                    tintColor: .bitcoinOrange,
                    textColor: Color(uiColor: .systemBackground),
                    isCapsule: true
                )
            )
            .padding()

        }

    }
}

#if DEBUG
    #Preview("OnboardingView - en") {
        OnboardingView(viewModel: .init(bdkClient: .mock))
    }
#endif
