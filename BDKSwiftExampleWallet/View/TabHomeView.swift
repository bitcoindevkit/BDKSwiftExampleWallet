//
//  TabHomeView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 6/15/23.
//

import SwiftUI

struct TabHomeView: View {
    @Bindable var viewModel: TabHomeViewModel
    @State private var showingTabViewErrorAlert = false

    var body: some View {

        ZStack {
            Color(uiColor: UIColor.systemBackground)

            TabView {
                WalletView(viewModel: .init())
                    .tabItem {
                        Image(systemName: "bitcoinsign")
                    }
                ReceiveView(viewModel: .init())
                    .tabItem {
                        Image(systemName: "arrow.down")
                    }
                AmountView(viewModel: .init())
                    .tabItem {
                        Image(systemName: "arrow.up")
                    }
                SettingsView(viewModel: .init())
                    .tabItem {
                        Image(systemName: "gear")
                    }
            }
            .tint(.primary)
            .onAppear {
                viewModel.loadWallet()
            }

        }
        .alert(isPresented: $showingTabViewErrorAlert) {
            Alert(
                title: Text("TabView Error"),
                message: Text(viewModel.tabViewError?.description ?? "Unknown"),
                dismissButton: .default(Text("OK")) {
                    viewModel.tabViewError = nil
                }
            )
        }

    }

}

#Preview {
    TabHomeView(viewModel: .init())
}
