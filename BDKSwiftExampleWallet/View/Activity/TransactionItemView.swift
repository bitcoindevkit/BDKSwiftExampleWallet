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

        VStack(alignment: .leading, spacing: 20) {

            let delta = txDetails.balanceDelta
            let prefix = (delta >= 0 ? "+ " : "- ").appending("\(format.displayPrefix) ")
            let amount = format.formatted(UInt64(abs(delta)), fiatPrice: fiatPrice)
            let suffix = format.displayText

            Text("\(prefix)\(amount) \(suffix)")
                .font(.title)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .lineLimit(1)
                .redacted(reason: isRedacted ? .placeholder : [])

            HStack {
                //                if isRedacted {
                //                    Image(
                //                        systemName:
                //                            "circle.fill"
                //                    )
                //                    .symbolRenderingMode(.palette)
                //                    .foregroundStyle(
                //                        Color.gray.opacity(0.5)
                //                    )
                //                } else {
                //                    ZStack {
                //                        Image(
                //                            systemName:
                //                                txDetails.balanceDelta >= 0
                //                                ? "arrow.down" : "arrow.up"
                //                        )
                //                        .foregroundStyle(
                //                            {
                //                                switch txDetails.chainPosition {
                //                                case .confirmed(_, _):
                //                                    Color.bitcoinOrange
                //                                case .unconfirmed(_):
                //                                    Color.gray.opacity(0.5)
                //                                }
                //                            }()
                //                        )
                //                    }
                //                }

                switch txDetails.chainPosition {
                case .confirmed(let confirmationBlockTime, _):
                    Text(
                        confirmationBlockTime.confirmationTime.toDate().formatted(
                            date: .abbreviated,
                            time: .shortened
                        )
                    )
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
                    .redacted(reason: isRedacted ? .placeholder : [])
                case .unconfirmed(let timestamp):
                    if let timestamp {
                        Text(
                            timestamp.toDate().formatted(
                                date: .abbreviated,
                                time: .shortened
                            )
                        )
                        .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
                        .redacted(reason: isRedacted ? .placeholder : [])
                    } else {
                        Text("Pending")
                            .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
                            .redacted(reason: isRedacted ? .placeholder : [])
                    }
                }

            }
            .foregroundStyle(.secondary)
            .font(.callout)

            HStack {
                Text(txDetails.txid.description)
                    .truncationMode(.middle)
                    .lineLimit(1)
                    .fontDesign(.monospaced)
                    .font(.callout)
                    .foregroundStyle(.primary)
                Spacer(minLength: 80)
            }
            .redacted(reason: isRedacted ? .placeholder : [])

        }
        .padding(.vertical)
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
