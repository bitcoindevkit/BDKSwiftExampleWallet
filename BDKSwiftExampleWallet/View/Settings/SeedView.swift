//
//  SeedView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 1/31/24.
//

import BitcoinUI
import SwiftUI

struct SeedView: View {
    @Bindable var viewModel: SeedViewModel
    @State private var isCopied = false
    @State private var showCheckmark = false

    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack {
                if let seed = viewModel.seed {

                    SeedPhraseView(
                        words: seed.mnemonic.components(separatedBy: " "),
                        preferredWordsPerRow: 2,
                        usePaging: true,
                        wordsPerPage: 6
                    )

                    HStack {
                        Spacer()
                        Button {
                            UIPasteboard.general.string = seed.mnemonic
                            isCopied = true
                            showCheckmark = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                isCopied = false
                                showCheckmark = false
                            }
                        } label: {
                            HStack {
                                Image(systemName: showCheckmark ? "checkmark" : "doc.on.doc")
                                Text("Copy")
                                    .bold()
                            }
                        }
                        .buttonStyle(
                            BitcoinFilled(
                                width: 120,
                                height: 40,
                                tintColor: .bitcoinOrange,
                                textColor: Color(uiColor: .systemBackground),
                                isCapsule: true
                            )
                        )
                        Spacer()
                    }
                    .padding()
                } else {
                    Text("No seed available")
                        .font(.headline)
                        .padding(.horizontal, 40.0)
                }
            }
            .padding()
            .onAppear {
                viewModel.getSeed()
            }
        }
        .alert(isPresented: $viewModel.showingSeedViewErrorAlert) {
            Alert(
                title: Text("Showing Seed Error"),
                message: Text(viewModel.seedViewError?.description ?? ""),
                dismissButton: .default(Text("OK")) {
                    viewModel.seedViewError = nil
                }
            )
        }

    }
}

#if DEBUG
    #Preview {
        SeedView(viewModel: .init(bdkService: .mock))
    }
#endif
