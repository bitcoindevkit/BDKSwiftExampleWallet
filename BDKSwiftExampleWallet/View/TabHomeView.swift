//
//  TabHomeView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 6/15/23.
//

import SwiftUI

struct TabHomeView: View {
    @Bindable var viewModel: TabHomeViewModel
    @State private var sendNavigationPath = NavigationPath()

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

                NavigationStack(path: $sendNavigationPath) {
                    AmountView(viewModel: .init(), navigationPath: $sendNavigationPath)
                        .navigationDestination(for: NavigationDestination.self) { destination in
                            switch destination {
                            case .address(let amount):
                                AddressView(amount: amount, navigationPath: $sendNavigationPath)
                            case .fee(let amount, let address):
                                FeeView(
                                    amount: amount,
                                    address: address,
                                    viewModel: .init(),
                                    navigationPath: $sendNavigationPath
                                )
                            case .buildTransaction(let amount, let address, let fee):
                                BuildTransactionView(
                                    amount: amount,
                                    address: address,
                                    fee: fee,
                                    viewModel: .init(),
                                    navigationPath: $sendNavigationPath
                                )
                            }
                        }
                }
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
