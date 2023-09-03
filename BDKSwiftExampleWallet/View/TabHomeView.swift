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
                            "",
                            systemImage: "bitcoinsign"
                        )
                    }

                ReceiveView(viewModel: .init())
                    .tabItem {
                        Label(
                            "",
                            systemImage: "arrow.down"
                        )
                    }

                SendView(viewModel: .init())
                    .tabItem {
                        Label(
                            "",
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
