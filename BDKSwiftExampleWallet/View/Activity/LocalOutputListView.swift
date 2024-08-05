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
                LocalOutputItemView(utxo: .mock, isRedacted: true)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
            } else if localOutputs.isEmpty {
                Text("No UTXOs")
                    .font(.subheadline)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
            } else {
                ForEach(localOutputs, id: \.outpoint) { utxo in
                    LocalOutputItemView(utxo: utxo, isRedacted: false)
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
