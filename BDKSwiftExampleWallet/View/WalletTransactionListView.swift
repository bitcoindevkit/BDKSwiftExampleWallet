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
    let transactionDetails: [TransactionDetails]
    let walletSyncState: WalletSyncState

    var body: some View {

        List {
            if transactionDetails.isEmpty && walletSyncState == .syncing {
                WalletTransactionsListItemView(transaction: mockTransactionDetail, isRedacted: true)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
            } else if transactionDetails.isEmpty {
                Text("No Transactions")
                    .font(.subheadline)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
            } else {
                ForEach(
                    transactionDetails.sorted(
                        by: {
                            $0.confirmationTime?.timestamp ?? $0.received > $1.confirmationTime?
                                .timestamp ?? $1.received
                        }
                    ),
                    id: \.txid
                ) { transaction in

                    NavigationLink(
                        destination: TransactionDetailsView(
                            transaction: transaction,
                            amount:
                                transaction.sent > 0
                                ? transaction.sent - transaction.received
                                : transaction.received - transaction.sent
                        )
                    ) {

                        WalletTransactionsListItemView(transaction: transaction)
                    }
                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            }

        }
        .listStyle(.plain)

    }
}

struct WalletTransactionsListItemView: View {
    let transaction: TransactionDetails
    let isRedacted: Bool
    @Environment(\.sizeCategory) var sizeCategory

    init(transaction: TransactionDetails, isRedacted: Bool = false) {
        self.transaction = transaction
        self.isRedacted = isRedacted
    }

    var body: some View {
        HStack(spacing: 15) {

            if isRedacted {
                Image(
                    systemName:
                        "circle.fill"
                )
                .font(.largeTitle)
                .symbolRenderingMode(.palette)
                .foregroundStyle(
                    Color.gray.opacity(0.5)
                )
            } else {
                Image(
                    systemName:
                        transaction.sent > 0
                        ? "arrow.up.circle.fill" : "arrow.down.circle.fill"
                )
                .font(.largeTitle)
                .symbolRenderingMode(.palette)
                .foregroundStyle(
                    transaction.confirmationTime != nil
                        ? Color.bitcoinOrange : Color.secondary,
                    isRedacted ? Color.gray.opacity(0.5) : Color.gray.opacity(0.05)
                )
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(transaction.txid)
                    .truncationMode(.middle)
                    .lineLimit(1)
                    .fontDesign(.monospaced)
                    .fontWeight(.semibold)
                    .font(.title)
                    .foregroundColor(.primary)
                Text(
                    transaction.confirmationTime?.timestamp.toDate().formatted(
                        .dateTime.day().month().hour().minute()
                    )
                        ?? "Unconfirmed"
                )
                .lineLimit(
                    sizeCategory > .accessibilityMedium ? 2 : 1
                )
            }
            .foregroundColor(.secondary)
            .font(.subheadline)
            .padding(.trailing, 30.0)
            .redacted(reason: isRedacted ? .placeholder : [])

            Spacer()
            Text(
                transaction.sent > 0
                    ? "- \(transaction.sent - transaction.received) sats"
                    : "+ \(transaction.received - transaction.sent) sats"
            )
            .font(.subheadline)
            .fontWeight(.semibold)
            .fontDesign(.rounded)
            .lineLimit(1)
            .redacted(reason: isRedacted ? .placeholder : [])
        }
        .padding(.vertical, 15.0)
        .padding(.vertical, 5.0)
        .minimumScaleFactor(0.5)

    }
}

#Preview {
    WalletTransactionListView(transactionDetails: mockTransactionDetails, walletSyncState: .synced)
}

#Preview {
    WalletTransactionListView(transactionDetails: mockTransactionDetails, walletSyncState: .synced)
        .environment(\.sizeCategory, .accessibilityLarge)
}
