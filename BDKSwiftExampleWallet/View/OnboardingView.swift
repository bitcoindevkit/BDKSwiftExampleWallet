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
    let pasteboard = UIPasteboard.general

    var body: some View {

        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack {

                HStack {
                    Spacer()
                    Button {
                        if viewModel.wordArray.isEmpty {
                            if let clipboardContent = UIPasteboard.general.string {
                                viewModel.words = clipboardContent
                            }
                        } else {
                            viewModel.words = ""
                        }
                    } label: {
                        Image(
                            systemName: viewModel.wordArray.isEmpty
                                ? "arrow.down.square" : "clear"
                        )
                        .contentTransition(.symbolEffect(.replace))
                    }
                    .tint(
                        viewModel.wordArray.isEmpty ? .secondary : .primary
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

                Text("Signet")
                    .foregroundStyle(.primary)
                    .fontWeight(.light)
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

    }
}

#if DEBUG
    #Preview("OnboardingView - en") {
        OnboardingView(viewModel: .init(bdkClient: .mock))
    }
#endif
