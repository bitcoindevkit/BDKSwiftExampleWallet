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
        Form {
            Section(header: Text("Network Connection")) {
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
                    } else {
                        HStack {
                            Text("Disconnected")
                        }
                    }
                }
                .foregroundColor(.bitcoinOrange)
            }
            Section(header: Text("Danger Zone")) {
                Button {
                    showingShowSeedConfirmation = true
                } label: {
                    Text(String(localized: "Show Seed"))
                        .foregroundStyle(.red)
                }
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
                        Text(String(localized: "Delete Seed"))
                            .foregroundStyle(.red)
                    }
                }
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
        }
        .navigationTitle(String("Settings"))
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

#Preview {
    SettingsView(viewModel: .init())
}

#Preview {
    SettingsView(viewModel: .init())
        .environment(\.sizeCategory, .accessibilityLarge)
}
