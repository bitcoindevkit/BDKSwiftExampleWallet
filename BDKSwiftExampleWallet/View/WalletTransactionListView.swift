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
                    transaction:
                        mockTransaction1!,
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
                                viewModel: .init(),
                                transaction: tx,
                                amount: sentAndReceivedValues.sent.toSat() == 0
                                && sentAndReceivedValues.received.toSat() > 0
                                ? sentAndReceivedValues.received.toSat() : sentAndReceivedValues.sent.toSat()
                            )
                        ) {
                            WalletTransactionsListItemView(
                                sentAndReceivedValues: sentAndReceivedValues,
                                transaction: tx,
                                isRedacted: false
                            )
                        }
                    } else {
                        Image(systemName: "questionmark")
                    }

                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)

            }

        }
        .listStyle(.plain)

    }
}

#if DEBUG
    #Preview {
        WalletTransactionListView(
            transactions: [
                mockCanonicalTx1,
                mockCanonicalTx2,
            ],
            walletSyncState: .synced,
            viewModel: .init()
        )
        .environment(\.colorScheme, .dark)
    }
    #Preview {
        WalletTransactionListView(
            transactions: [
                mockCanonicalTx1,
                mockCanonicalTx2,
            ],
            walletSyncState: .synced,
            viewModel: .init()
        )
        .environment(\.colorScheme, .dark)
    }
    #Preview {
        WalletTransactionListView(
            transactions: [
                mockCanonicalTx1,
                mockCanonicalTx2,
            ],
            walletSyncState: .synced,
            viewModel: .init()
        )
        .environment(\.sizeCategory, .accessibilityLarge)
    }
#endif
