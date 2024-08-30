//
//  HomeView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 6/15/23.
//

import SwiftUI

struct HomeView: View {
    @Bindable var viewModel: HomeViewModel

    var body: some View {

        ZStack {
            Color(uiColor: UIColor.systemBackground)

            WalletView(
                viewModel: .init(
                    priceClient: .live,
                    bdkClient: .live
                )
            )
            .tint(.primary)
            .onAppear {
                viewModel.loadWallet()
            }

        }
        .alert(isPresented: $viewModel.showingHomeViewErrorAlert) {
            Alert(
                title: Text("HomeView Error"),
                message: Text(viewModel.homeViewError?.description ?? "Unknown"),
                dismissButton: .default(Text("OK")) {
                    viewModel.homeViewError = nil
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
        HomeView(viewModel: .init(bdkClient: .mock))
    }
    #Preview {
        HomeView(viewModel: .init())
            .environment(\.dynamicTypeSize, .accessibility5)
    }
#endif
