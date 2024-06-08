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

        NavigationView {

            Form {
                Section(header: Text("Network")) {
                    if let network = viewModel.network, let url = viewModel.esploraURL {
                        Text(network.capitalized)
                            .foregroundColor(.primary)
                        Text(
                            url.replacingOccurrences(
                                of: "https://",
                                with: ""
                            ).replacingOccurrences(
                                of: "http://",
                                with: ""
                            )
                        )
                        .foregroundColor(.primary)
                    } else {
                        HStack {
                            Text("No Network")
                        }
                    }
                }
                Section(header: Text("Wallet")) {
                    Button {
                        Task {
                            await viewModel.fullScanWithProgress()
                        }
                    } label: {
                        Text("Full Scan")
                    }
                    .foregroundColor(.bitcoinOrange)
                    if viewModel.walletSyncState == .syncing {
                        Text("\(viewModel.inspectedScripts)")
                            .contentTransition(.numericText())
                            .foregroundColor(.primary)
                            .animation(.easeInOut, value: viewModel.inspectedScripts)
                    }
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
            .navigationTitle("Settings")
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

}

#if DEBUG
    #Preview {
        SettingsView(viewModel: .init(bdkClient: .mock, keyClient: .mock))
    }
    #Preview {
        SettingsView(viewModel: .init(bdkClient: .mock, keyClient: .mock))
            .environment(\.dynamicTypeSize, .accessibility5)
    }
#endif
