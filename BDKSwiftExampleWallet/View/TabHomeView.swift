//
//  TabHomeView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 6/15/23.
//

import SwiftUI

struct TabHomeView: View {

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
            }
            .tint(.primary)

        }

    }

}

#Preview{
    TabHomeView()
}
