//
//  WalletTransactionsListItemView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 4/3/24.
//

import BitcoinDevKit
import SwiftUI

struct WalletTransactionsListItemView: View {
    let sentAndReceivedValues: SentAndReceivedValues
    let transaction: BitcoinDevKit.Transaction
    let isRedacted: Bool
    @Environment(\.sizeCategory) var sizeCategory

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
                        sentAndReceivedValues.sent == 0
                        && sentAndReceivedValues.received > 0
                        ? "arrow.up.circle.fill" : "arrow.down.circle.fill"
                )
                .font(.largeTitle)
                .symbolRenderingMode(.palette)
                .foregroundStyle(Color.gray.opacity(0.5))  // TODO: foreground style, used to be based on confirmation time
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(transaction.txid())
                    .truncationMode(.middle)
                    .lineLimit(1)
                    .fontDesign(.monospaced)
                    .fontWeight(.semibold)
                    .font(.title)
                    .foregroundColor(.primary)
                Text(
                    "{Confirmation Status / Timestamp}"
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
                sentAndReceivedValues.sent == 0
                    && sentAndReceivedValues.received > 0
                    ? "+ \(sentAndReceivedValues.received) sats"
                    : "- \(sentAndReceivedValues.sent - sentAndReceivedValues.received) sats"

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

#if DEBUG
    #Preview {
        WalletTransactionsListItemView(
            sentAndReceivedValues: SentAndReceivedValues.init(
                sent: UInt64(100),
                received: UInt64(200)
            ),
            transaction: mockTransaction1!,
            isRedacted: false
        )
    }
#endif
