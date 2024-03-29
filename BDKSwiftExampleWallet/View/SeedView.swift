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
                ForEach(
                    Array(viewModel.seed.mnemonic.components(separatedBy: " ").enumerated()),
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
                        UIPasteboard.general.string = viewModel.seed.mnemonic
                        isCopied = true
                        showCheckmark = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isCopied = false
                            showCheckmark = false
                        }
                    } label: {
                        HStack {
                            withAnimation {
                                HStack {
                                    Image(
                                        systemName: showCheckmark
                                            ? "checkmark" : "doc.on.doc"
                                    )
                                    Text("Copy")
                                }
                            }
                        }
                        .bold()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.bitcoinOrange)
                    Spacer()
                }
                .padding()
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

#Preview {
    SeedView(viewModel: .init())
}

#Preview {
    SeedView(viewModel: .init())
        .environment(\.sizeCategory, .accessibilityLarge)
}
