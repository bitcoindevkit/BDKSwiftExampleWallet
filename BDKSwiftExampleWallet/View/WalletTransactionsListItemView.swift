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
    let canonicalTx: CanonicalTx
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
                        sentAndReceivedValues.sent.toSat() == 0
                        && sentAndReceivedValues.received.toSat() > 0
                        ? "arrow.up.circle.fill" : "arrow.down.circle.fill"
                )
                .font(.largeTitle)
                .symbolRenderingMode(.palette)
                .foregroundStyle(Color.gray.opacity(0.5))  // TODO: foreground style, used to be based on confirmation time
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(canonicalTx.transaction.txid())
                    .truncationMode(.middle)
                    .lineLimit(1)
                    .fontDesign(.monospaced)
                    .fontWeight(.semibold)
                    .font(.title)
                    .foregroundColor(.primary)
                switch canonicalTx.chainPosition {
                case .confirmed(_, let timestamp):
                    Text(
                        timestamp.toDate().formatted(
                            date: .abbreviated,
                            time: Date.FormatStyle.TimeStyle.shortened
                        )
                    )
                    .lineLimit(
                        sizeCategory > .accessibilityMedium ? 2 : 1
                    )
                case .unconfirmed(let timestamp):
                    Text(
                        timestamp.toDate().formatted(
                            date: .abbreviated,
                            time: Date.FormatStyle.TimeStyle.shortened
                        )
                    )
                    .lineLimit(
                        sizeCategory > .accessibilityMedium ? 2 : 1
                    )
                }
            }
            .foregroundColor(.secondary)
            .font(.subheadline)
            .padding(.trailing, 30.0)
            .redacted(reason: isRedacted ? .placeholder : [])

            Spacer()

            Text(
                sentAndReceivedValues.sent.toSat() == 0
                    && sentAndReceivedValues.received.toSat() > 0
                    ? "+ \(sentAndReceivedValues.received.toSat()) sats"
                    : "- \(sentAndReceivedValues.sent.toSat() - sentAndReceivedValues.received.toSat()) sats"

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
                sent: Amount.fromSat(fromSat: UInt64(100)),
                received: Amount.fromSat(fromSat: UInt64(200))
            ),
            canonicalTx: mockCanonicalTx1,
            isRedacted: false
        )
    }
#endif
