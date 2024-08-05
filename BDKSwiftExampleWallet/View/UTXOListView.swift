//
//  UTXOListView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/4/24.
//

import BitcoinDevKit
import SwiftUI

struct UTXOListView: View {
    let utxos: [LocalOutput]
    let walletSyncState: WalletSyncState

    var body: some View {
        List {
            if utxos.isEmpty && walletSyncState == .syncing {
                UTXOListItemView(utxo: .mock, isRedacted: true)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
            } else if utxos.isEmpty {
                Text("No UTXOs")
                    .font(.subheadline)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
            } else {
                ForEach(utxos, id: \.outpoint) { utxo in
                    UTXOListItemView(utxo: utxo, isRedacted: false)
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
    UTXOListView(utxos: [.mock], walletSyncState: .synced)
}
