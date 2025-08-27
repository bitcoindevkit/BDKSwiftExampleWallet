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
    let fiatPrice: Double

    var body: some View {
        List {
            if localOutputs.isEmpty && walletSyncState == .syncing {
                LocalOutputItemView(
                    isRedacted: true,
                    output: .mock,
                    fiatPrice: .zero
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
                        output: output,
                        fiatPrice: fiatPrice
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
    LocalOutputListView(localOutputs: [.mock], walletSyncState: .synced, fiatPrice: 714.23)
}
