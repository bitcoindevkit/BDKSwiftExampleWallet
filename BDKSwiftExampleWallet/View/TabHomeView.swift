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
                        Label(
                            "Wallet",
                            systemImage: "bitcoinsign"
                        )
                    }

                ReceiveView(viewModel: .init())
                    .tabItem {
                        Label(
                            "Receive",
                            systemImage: "arrow.down"
                        )
                    }

                SendView(viewModel: .init())
                    .tabItem {
                        Label(
                            "Send",
                            systemImage: "arrow.up"
                        )
                    }

            }
            .tint(.primary)
        }

    }

}

#Preview{
    TabHomeView()
}
