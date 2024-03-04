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
    let transactions: [BitcoinDevKit.Transaction]
    let walletSyncState: WalletSyncState
    @Bindable var viewModel: WalletTransactionsListViewModel

    var body: some View {

        List {
            if transactions.isEmpty && walletSyncState == .syncing {
                WalletTransactionsListItemView(
                    sentAndReceivedValues: .init(
                        sent: UInt64(0),
                        received: UInt64(0)
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
                    transactions.sorted(
                        by: { $0.vsize() > $1.vsize() }
                    ),
                    id: \.transactionID
                ) { transaction in

                    let sentAndReceivedValues = viewModel.getSentAndReceived(tx: transaction)
                    if let sentAndReceivedValue = sentAndReceivedValues {
                        NavigationLink(
                            destination:
                                TransactionDetailsView(
                                    viewModel: .init(),
                                    transaction: transaction,
                                    amount: sentAndReceivedValue.sent == 0
                                        && sentAndReceivedValue.received > 0
                                        ? sentAndReceivedValue.received : sentAndReceivedValue.sent
                                )
                        ) {
                            WalletTransactionsListItemView(
                                sentAndReceivedValues: sentAndReceivedValue,
                                transaction: transaction,
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
                mockTransaction1!,
                mockTransaction2!,
            ],
            walletSyncState: .synced,
            viewModel: .init()
        )
        .environment(\.colorScheme, .dark)
    }
    #Preview {
        WalletTransactionListView(
            transactions: [
                mockTransaction1!,
                mockTransaction2!,
            ],
            walletSyncState: .synced,
            viewModel: .init()
        )
        .environment(\.colorScheme, .dark)
    }
    #Preview {
        WalletTransactionListView(
            transactions: [
                mockTransaction1!,
                mockTransaction2!,
            ],
            walletSyncState: .synced,
            viewModel: .init()
        )
        .environment(\.sizeCategory, .accessibilityLarge)
    }
#endif
