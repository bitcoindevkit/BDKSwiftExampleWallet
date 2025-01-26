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
    var isSmallDevice: Bool {
        UIScreen.main.isPhoneSE
    }
    @State private var animateContent = false

    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack {
                HStack(alignment: .center, spacing: 40) {
                    Spacer()

                    if viewModel.words.isEmpty {
                        Button {
                            showingScanner = true
                        } label: {
                            Image(systemName: "qrcode.viewfinder")
                                .transition(.symbolEffect(.disappear))
                        }
                        .tint(.secondary)
                        .font(.title)
                        .opacity(animateContent ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(1.2), value: animateContent)

                        Button {
                            if let clipboardContent = UIPasteboard.general.string {
                                viewModel.words = clipboardContent
                            }
                        } label: {
                            Image(systemName: "arrow.down.square")
                                .contentTransition(.symbolEffect(.replace))
                        }
                        .tint(.secondary)
                        .font(.title)
                        .opacity(animateContent ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(1.2), value: animateContent)
                    } else {
                        Button {
                            viewModel.words = ""
                        } label: {
                            Image(systemName: "clear")
                                .contentTransition(.symbolEffect(.replace))
                        }
                        .tint(.primary)
                        .font(.title)
                    }
                }
                .padding()

                Spacer()

                VStack(spacing: isSmallDevice ? 5 : 25) {
                    Image(systemName: "bitcoinsign.circle")
                        .resizable()
                        .foregroundStyle(.secondary)
                        .frame(
                            width: isSmallDevice ? 40 : 100,
                            height: isSmallDevice ? 40 : 100,
                            alignment: .center
                        )
                        .scaleEffect(animateContent ? 1 : 0)
                        .opacity(animateContent ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.5, blendDuration: 0.6), value: animateContent)
                    
                    Text("powered by Bitcoin Dev Kit")
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [.secondary, .primary]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .fontWidth(.expanded)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding()
                        .opacity(animateContent ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.6), value: animateContent)
                }
                .padding()

                Group {
                    Picker("Network", selection: $viewModel.selectedNetwork) {
                        Text("Signet").tag(Network.signet)
                        Text("Testnet").tag(Network.testnet)
                    }
                    .pickerStyle(.automatic)
                    .tint(.primary)
                    .accessibilityLabel("Select Bitcoin Network")
                    .opacity(animateContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(1.5), value: animateContent)

                    Picker("Esplora Server", selection: $viewModel.selectedURL) {
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
                    .opacity(animateContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(1.5), value: animateContent)
                }

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
                        .frame(
                            height: isSmallDevice ? 150 : 200
                        )
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
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 50)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(1.2), value: animateContent)
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
        .onAppear {
            withAnimation {
                animateContent = true
            }
        }
    }
}

#if DEBUG
    #Preview("OnboardingView - en") {
        OnboardingView(viewModel: .init(bdkClient: .mock))
    }
#endif
