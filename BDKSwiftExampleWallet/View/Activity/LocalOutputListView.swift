//
//  LocalOutputListView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/4/24.
//

import BitcoinDevKit
import SwiftUI

struct LocalOutputListView: View {
    let localOutputs: [LocalOutput]
    let walletSyncState: WalletSyncState

    var body: some View {
        List {
            if localOutputs.isEmpty && walletSyncState == .syncing {
                LocalOutputItemView(
                    isRedacted: true,
                    output: .mock
                )
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            } else if localOutputs.isEmpty {
                Text("No Unspent")
                    .font(.subheadline)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
            } else {
                ForEach(localOutputs, id: \.outpoint) { output in
                    LocalOutputItemView(
                        isRedacted: false,
                        output: output
                    )
                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
    }
}

#Preview {
    LocalOutputListView(localOutputs: [.mock], walletSyncState: .synced)
}
