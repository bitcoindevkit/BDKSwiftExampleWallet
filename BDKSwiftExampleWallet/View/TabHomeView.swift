//
//  TabHomeView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 6/15/23.
//

import SwiftUI

struct TabHomeView: View {
    @Bindable var viewModel: TabHomeViewModel

    var body: some View {

        ZStack {
            Color(uiColor: UIColor.systemBackground)

            TabView {
                WalletView(
                    viewModel: .init(
                        priceClient: .live,
                        bdkClient: .live
                    )
                )
                .tabItem {
                    Image(systemName: "bitcoinsign")
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
        .alert(isPresented: $viewModel.showingTabViewErrorAlert) {
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

enum NavigationDestination: Hashable {
    case amount
    case address(amount: String)
    case fee(amount: String, address: String)
    case buildTransaction(amount: String, address: String, fee: Int)
}

#if DEBUG
    #Preview {
        TabHomeView(viewModel: .init(bdkClient: .mock))
    }
    #Preview {
        TabHomeView(viewModel: .init())
            .environment(\.dynamicTypeSize, .accessibility5)
    }
#endif
