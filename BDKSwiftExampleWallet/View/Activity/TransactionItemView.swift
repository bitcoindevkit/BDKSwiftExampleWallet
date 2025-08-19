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
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    let txDetails: TxDetails
    let isRedacted: Bool
    private let format: BalanceDisplayFormat
    private var fiatPrice: Double
    
    init(
        txDetails: TxDetails,
        isRedacted: Bool,
        format: BalanceDisplayFormat,
        fiatPrice: Double
    ) {
        self.txDetails = txDetails
        self.isRedacted = isRedacted
        self.format = format
        self.fiatPrice = fiatPrice
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
                ZStack {
                    Image(systemName: "circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(Color.gray.opacity(0.25))
                    Image(
                        systemName:
                            txDetails.balanceDelta >= 0
                            ? "arrow.down" : "arrow.up"
                    )
                    .font(.callout)
                    .foregroundStyle(
                        {
                            switch txDetails.chainPosition {
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
                Text(txDetails.txid.description)
                    .truncationMode(.middle)
                    .lineLimit(1)
                    .fontDesign(.monospaced)
                    .fontWeight(.semibold)
                    .font(.title)
                    .foregroundStyle(.primary)
                switch txDetails.chainPosition {
                case .confirmed(let confirmationBlockTime, _):
                    Text(
                        confirmationBlockTime.confirmationTime.toDate().formatted(
                            date: .abbreviated,
                            time: .shortened
                        )
                    )
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
                    .font(.caption2)
                    .fontWidth(.condensed)
                case .unconfirmed(let timestamp):
                    if let timestamp {
                        Text(
                            timestamp.toDate().formatted(
                                date: .abbreviated,
                                time: .shortened
                            )
                        )
                        .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
                        .font(.caption2)
                        .fontWidth(.condensed)
                    } else {
                        Text("Pending")
                            .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
                            .font(.caption2)
                            .fontWidth(.condensed)
                    }
                }
            }
            .foregroundStyle(.secondary)
            .font(.subheadline)
            .padding(.trailing, 30.0)
            .redacted(reason: isRedacted ? .placeholder : [])

            Spacer()

            let delta = txDetails.balanceDelta
            let prefix = (delta >= 0 ? "+ " : "- ").appending("\(format.displayPrefix) ")
            let amount = format.formatted(UInt64(abs(delta)), fiatPrice: fiatPrice)
            let suffix = format.displayText

            Text("\(prefix)\(amount) \(suffix)")
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
            txDetails: .mock,
            isRedacted: false,
            format: .bip177,
            fiatPrice: 714.23
        )
    }
#endif
