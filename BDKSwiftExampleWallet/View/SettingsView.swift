//
//  SettingsView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 1/24/24.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State private var showingDeleteSeedConfirmation = false

    var body: some View {

        ZStack {

            Color(uiColor: UIColor.systemBackground)

            VStack(spacing: 20.0) {

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

        }

    }

}

#Preview {
    SettingsView(viewModel: .init())
}
