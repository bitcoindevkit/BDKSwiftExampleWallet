//
//  WalletTransactionListView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/6/23.
//

import BitcoinDevKit
import BitcoinUI
import SwiftUI

struct WalletTransactionListView: View {
    let transactions: [CanonicalTx]
    let walletSyncState: WalletSyncState
    @Bindable var viewModel: WalletTransactionsListViewModel

    var body: some View {

        List {
            if transactions.isEmpty && walletSyncState == .syncing {
                WalletTransactionsListItemView(
                    sentAndReceivedValues: .init(
                        sent: Amount.fromSat(fromSat: UInt64(0)),
                        received: Amount.fromSat(fromSat: UInt64(0))
                    ),
                    canonicalTx: .mock,
                    isRedacted: true
                )
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            } else if transactions.isEmpty {
                Text("No Transactions")
                    .font(.subheadline)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
            } else {

                ForEach(
                    transactions.sorted(by: { $0.transaction.vsize() > $1.transaction.vsize() }),
                    id: \.transaction.transactionID
                ) { item in
                    let canonicalTx = item
                    let tx = canonicalTx.transaction
                    if let sentAndReceivedValues = viewModel.getSentAndReceived(tx: tx) {
                        NavigationLink(
                            destination: TransactionDetailsView(
                                viewModel: .init(bdkClient: .live, keyClient: .live),
                                canonicalTx: canonicalTx,
                                amount: sentAndReceivedValues.sent.toSat() == 0
                                    && sentAndReceivedValues.received.toSat() > 0
                                    ? sentAndReceivedValues.received.toSat()
                                    : sentAndReceivedValues.sent.toSat()
                            )
                        ) {
                            WalletTransactionsListItemView(
                                sentAndReceivedValues: sentAndReceivedValues,
                                canonicalTx: canonicalTx,
                                isRedacted: false
                            )
                        }
                    } else {
                        Image(systemName: "questionmark")
                    }

                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

            }

        }
        .listStyle(.plain)

    }
}

#if DEBUG
    #Preview {
        WalletTransactionListView(
            transactions: [
                .mock
            ],
            walletSyncState: .synced,
            viewModel: .init(
                bdkClient: .mock
            )
        )
    }
    #Preview {
        WalletTransactionListView(
            transactions: [
                .mock
            ],
            walletSyncState: .synced,
            viewModel: .init(
                bdkClient: .mock
            )
        )
        .environment(\.sizeCategory, .accessibilityLarge)
    }
#endif
