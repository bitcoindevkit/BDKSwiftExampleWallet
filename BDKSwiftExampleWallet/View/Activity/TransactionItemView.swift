//
//  TransactionItemView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 4/3/24.
//

import BitcoinDevKit
import BitcoinUI
import SwiftUI

struct TransactionItemView: View {
    let sentAndReceivedValues: SentAndReceivedValues
    let canonicalTx: CanonicalTx
    let isRedacted: Bool
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

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
                ZStack {
                    Image(systemName: "circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(Color.gray.opacity(0.25))
                    Image(
                        systemName:
                            sentAndReceivedValues.sent.toSat() == 0
                            && sentAndReceivedValues.received.toSat() > 0
                            ? "arrow.down" : "arrow.up"
                    )
                    .font(.callout)
                    .foregroundStyle(
                        {
                            switch canonicalTx.chainPosition {
                            case .confirmed(_, _):
                                Color.bitcoinOrange
                            case .unconfirmed(_):
                                Color.gray.opacity(0.5)
                            }
                        }()
                    )
                }
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(canonicalTx.transaction.computeTxid())
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
                            time: .shortened
                        )
                    )
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
                    .font(.caption2)
                    .fontWidth(.condensed)
                case .unconfirmed(let timestamp):
                    Text(
                        timestamp.toDate().formatted(
                            date: .abbreviated,
                            time: .shortened
                        )
                    )
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
                    .font(.caption2)
                    .fontWidth(.condensed)
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
        TransactionItemView(
            sentAndReceivedValues: .mock,
            canonicalTx: .mock,
            isRedacted: false
        )
    }
    #Preview {
        TransactionItemView(
            sentAndReceivedValues: .mock,
            canonicalTx: .mock,
            isRedacted: false
        )
    }
#endif
