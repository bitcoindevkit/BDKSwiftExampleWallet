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

    var body: some View {
        List {
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
                    HStack(spacing: 15) {
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
                            Color.gray.opacity(0.05)
                        )
                        VStack(alignment: .leading, spacing: 5) {
                            Text(transaction.txid)
                                .truncationMode(.middle)
                                .lineLimit(1)
                                .fontDesign(.monospaced)
                                .fontWeight(.semibold)
                                .font(.callout)
                                .foregroundColor(.primary)
                            Text(
                                transaction.confirmationTime?.timestamp.toDate().formatted(
                                    .dateTime.day().month().hour().minute()
                                )
                                    ?? "Unconfirmed"
                            )
                        }
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .padding(.trailing, 30.0)
                        Spacer()
                        Text(
                            transaction.sent > 0
                                ? "- \(transaction.sent - transaction.received) sats"
                                : "+ \(transaction.received - transaction.sent) sats"
                        )
                        .font(.caption)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                    }
                    .padding(.vertical, 15.0)
                    .padding(.vertical, 5.0)
                }

            }
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)

        }
        .listStyle(.plain)
    }
}

#Preview{
    WalletTransactionListView(transactionDetails: mockTransactionDetails)
}
