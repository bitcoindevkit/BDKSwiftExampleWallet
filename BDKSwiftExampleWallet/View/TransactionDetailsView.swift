//
//  TransactionDetailsView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 6/22/23.
//

import BitcoinDevKit
import BitcoinUI
import SwiftUI

struct TransactionDetailsView: View {
    let transaction: TransactionDetails
    let amount: UInt64
    @State private var isCopied = false
    @State private var showCheckmark = false

    var body: some View {

        VStack {

            VStack(spacing: 8) {
                Image(systemName: "bitcoinsign.circle.fill")
                    .resizable()
                    .foregroundColor(.bitcoinOrange)
                    .fontWeight(.bold)
                    .frame(width: 50, height: 50, alignment: .center)
                HStack(spacing: 3) {
                    Text(
                        transaction.sent > 0 ? "Send" : "Receive"
                    )
                    if transaction.confirmationTime == nil {
                        Text("Unconfirmed")
                    } else {
                        Text("Confirmed")
                    }
                }
                .fontWeight(.semibold)
                if let height = transaction.confirmationTime?.height {
                    Text("Block \(height.delimiter)")
                        .foregroundColor(.secondary)
                }
            }
            .font(.caption)

            Spacer()

            VStack(spacing: 8) {
                HStack {
                    Text(amount.delimiter)
                    Text("sats")
                }
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .font(.largeTitle)
                .foregroundColor(.primary)
                .fontWeight(.bold)
                .fontDesign(.rounded)
                VStack(spacing: 4) {
                    if transaction.confirmationTime == nil {
                        Text("Unconfirmed")
                    } else {
                        VStack {
                            if let timestamp = transaction.confirmationTime?.timestamp {
                                Text(
                                    timestamp.toDate().formatted(
                                        date: .abbreviated,
                                        time: Date.FormatStyle.TimeStyle.shortened
                                    )
                                )
                            }
                        }
                    }
                    if let fee = transaction.fee {
                        Text("\(fee) sats fee")
                    }
                }
                .foregroundColor(.secondary)
                .font(.callout)
            }

            Spacer()

            HStack {
                Text(transaction.txid)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Spacer()
                Button {
                    UIPasteboard.general.string = transaction.txid
                    isCopied = true
                    showCheckmark = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isCopied = false
                        showCheckmark = false
                    }
                } label: {
                    HStack {
                        withAnimation {
                            Image(systemName: showCheckmark ? "checkmark" : "doc.on.doc")
                        }
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.bitcoinOrange)
                }
            }
            .fontDesign(.monospaced)
            .font(.caption)
            .padding()

        }
        .padding()

    }
}

#Preview {
    TransactionDetailsView(transaction: mockTransactionDetail, amount: UInt64(10_000_000))
}

#Preview {
    TransactionDetailsView(transaction: mockTransactionDetail, amount: UInt64(10_000_000))
        .environment(\.sizeCategory, .accessibilityLarge)
}
