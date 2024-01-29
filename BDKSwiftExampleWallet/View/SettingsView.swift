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
    @State private var showingSettingsViewErrorAlert = false

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

        }
        .alert(isPresented: $showingSettingsViewErrorAlert) {
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
