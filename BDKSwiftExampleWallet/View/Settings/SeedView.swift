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
                if let backupInfo = viewModel.backupInfo,
                    let publicDescriptor = viewModel.publicDescriptor,
                    let publicChangeDescriptor = viewModel.publicChangeDescriptor
                {

                    SeedPhraseView(
                        words: backupInfo.mnemonic.components(separatedBy: " "),
                        preferredWordsPerRow: 2,
                        usePaging: true,
                        wordsPerPage: 4
                    )

                    VStack {
                        Text("Seed is not synced across devices.")
                        Text("Please make sure to write it down and store it securely.")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()

                    HStack {
                        Spacer()
                        Button {
                            UIPasteboard.general.string = backupInfo.mnemonic
                            isCopied = true
                            showCheckmark = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                                isCopied = false
                                showCheckmark = false
                            }
                        } label: {
                            HStack {
                                Image(
                                    systemName: showCheckmark
                                        ? "document.on.document.fill" : "document.on.document"
                                )
                                .contentTransition(.symbolEffect(.replace))
                                Text("Seed")
                                    .bold()
                            }
                        }
                        .buttonStyle(
                            BitcoinFilled(
                                width: 120,
                                height: 40,
                                tintColor: .primary,
                                textColor: Color(uiColor: .systemBackground),
                                isCapsule: true
                            )
                        )
                        Spacer()
                    }

                    HStack {
                        Spacer()

                        let formattedDescriptors = """
                            External Private: \(backupInfo.descriptor)

                            External Public: \(publicDescriptor)

                            Internal Private: \(backupInfo.changeDescriptor)

                            Internal Public: \(publicChangeDescriptor)
                            """

                        ShareLink(item: formattedDescriptors) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Descriptors")
                                    .bold()
                            }
                        }
                        .buttonStyle(
                            BitcoinFilled(
                                width: 160,
                                height: 40,
                                tintColor: .primary,
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
                let network = viewModel.getNetwork()
                viewModel.getBackupInfo(network: network)
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
        SeedView(viewModel: .init(bdkClient: .mock))
    }
#endif
