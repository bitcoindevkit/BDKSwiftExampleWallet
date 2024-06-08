//
//  SeedView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 1/31/24.
//

import SwiftUI

struct SeedView: View {
    @Bindable var viewModel: SeedViewModel
    @State private var isCopied = false
    @State private var showCheckmark = false

    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack(alignment: .leading) {
                if let seed = viewModel.seed {
                    ForEach(
                        Array(seed.mnemonic.components(separatedBy: " ").enumerated()),
                        id: \.element
                    ) { index, word in
                        HStack {
                            Text("\(index + 1). \(word)")
                            Spacer()
                        }
                        .padding(.horizontal, 40.0)
                    }

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
                        .buttonStyle(.borderedProminent)
                        .tint(.bitcoinOrange)
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

    #Preview {
        SeedView(viewModel: .init(bdkService: .mock))
            .environment(\.dynamicTypeSize, .accessibility5)
    }
#endif
