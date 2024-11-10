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
    @AppStorage("isOnboarding") var isOnboarding: Bool?
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var showingOnboardingViewErrorAlert = false
    @State private var showingImportView = false
    @State private var showingScanner = false
    let pasteboard = UIPasteboard.general

    var body: some View {

        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack {

                HStack {

                    Spacer()

                    Button {
                        showingScanner = true
                    } label: {
                        Image(
                            systemName: viewModel.words.isEmpty
                                ? "qrcode.viewfinder" : "clear"
                        )
                        .contentTransition(.symbolEffect(.replace))
                    }
                    .tint(
                        viewModel.words.isEmpty ? .secondary : .primary
                    )
                    .font(.title)
                    .padding()

                    Button {
                        if viewModel.words.isEmpty {
                            if let clipboardContent = UIPasteboard.general.string {
                                viewModel.words = clipboardContent
                            }
                        } else {
                            viewModel.words = ""
                        }
                    } label: {
                        Image(
                            systemName: viewModel.words.isEmpty
                                ? "arrow.down.square" : "clear"
                        )
                        .contentTransition(.symbolEffect(.replace))
                    }
                    .tint(
                        viewModel.words.isEmpty ? .secondary : .primary
                    )
                    .font(.title)
                    .padding()
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
                }
                .pickerStyle(.automatic)
                .tint(.primary)
                .accessibilityLabel("Select Bitcoin Network")

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

                if !viewModel.words.isEmpty {
                    if viewModel.isDescriptor || viewModel.isXPub {
                        Text(viewModel.words)
                            .font(.system(.caption, design: .monospaced))
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .padding()
                    } else {
                        SeedPhraseView(
                            words: viewModel.wordArray,
                            preferredWordsPerRow: 2,
                            usePaging: true,
                            wordsPerPage: 4
                        )
                        .frame(height: 200)
                        .padding()
                    }
                }

                Spacer()

                Button("Create Wallet") {
                    viewModel.createWallet()
                }
                .buttonStyle(
                    BitcoinFilled(
                        tintColor: .primary,
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
        .sheet(isPresented: $showingScanner) {
            CustomScannerView(
                codeTypes: [.qr],
                completion: { result in
                    switch result {
                    case .success(let result):
                        viewModel.words = result.string
                        showingScanner = false
                    case .failure(let error):
                        viewModel.onboardingViewError = .generic(
                            message: error.localizedDescription
                        )
                        showingScanner = false
                    }
                },
                pasteAction: {}
            )
        }

    }
}

#if DEBUG
    #Preview("OnboardingView - en") {
        OnboardingView(viewModel: .init(bdkClient: .mock))
    }
#endif
