//
//  SettingsView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 1/24/24.
//

import BitcoinUI
import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State private var showingDeleteSeedConfirmation = false
    @State private var showingShowSeedConfirmation = false
    @State private var isSeedPresented = false

    var body: some View {

        ZStack {

            Color(uiColor: UIColor.systemBackground)

            VStack(spacing: 20.0) {

                VStack {
                    if let network = viewModel.network, let url = viewModel.esploraURL {
                        Text("Network: \(network)".uppercased()).bold()
                        Text(
                            url.replacingOccurrences(
                                of: "https://",
                                with: ""
                            ).replacingOccurrences(
                                of: "http://",
                                with: ""
                            )
                        )
                    }

                }
                .foregroundColor(.bitcoinOrange)

                Text("Danger Zone")
                    .bold()
                    .foregroundColor(.red)
                    .padding()

                Button {
                    showingShowSeedConfirmation = true
                } label: {
                    HStack {
                        Image(systemName: "list.number")
                        Text("Show Seed")
                    }
                    .foregroundColor(Color(uiColor: UIColor.systemBackground))
                    .bold()
                }
                .buttonBorderShape(.capsule)
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .alert(
                    "Are you sure you want to view the seed?",
                    isPresented: $showingShowSeedConfirmation
                ) {
                    Button("Yes", role: .destructive) {
                        isSeedPresented = true
                    }
                    Button("No", role: .cancel) {}
                }

                Button {
                    showingDeleteSeedConfirmation = true
                } label: {
                    HStack {
                        Image(systemName: "minus")
                        Text("Delete Seed")
                    }
                    .foregroundColor(Color(uiColor: UIColor.systemBackground))
                    .bold()
                }
                .buttonBorderShape(.capsule)
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .alert(
                    "Are you sure you want to delete the seed?",
                    isPresented: $showingDeleteSeedConfirmation
                ) {
                    Button("Yes", role: .destructive) {
                        viewModel.delete()
                    }
                    Button("No", role: .cancel) {}
                }

            }
            .onAppear {
                viewModel.getNetwork()
                viewModel.getEsploraUrl()
            }
            .sheet(
                isPresented: $isSeedPresented
            ) {
                SeedView(viewModel: .init())
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }

        }
        .alert(isPresented: $viewModel.showingSettingsViewErrorAlert) {
            Alert(
                title: Text("Settings Error"),
                message: Text(viewModel.settingsError?.description ?? "Unknown"),
                dismissButton: .default(Text("OK")) {
                    viewModel.settingsError = nil
                }
            )
        }

    }

}

#if DEBUG
    #Preview {
        SettingsView(viewModel: .init())
    }

    #Preview {
        SettingsView(viewModel: .init())
            .environment(\.sizeCategory, .accessibilityLarge)
    }
#endif
