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

            VStack {
                Image(systemName: "bitcoinsign.circle.fill")
                    .resizable()
                    .foregroundColor(.bitcoinOrange)
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
                if let height = transaction.confirmationTime?.height {
                    Text("Block \(height.delimiter)")
                }
            }
            .font(.caption)
            .fontWeight(.light)

            Spacer()

            VStack {
                HStack {
                    Text(amount.delimiter)
                    Text("sats")
                }
                .font(.largeTitle)
                .foregroundColor(.primary)
                .fontWidth(.compressed)
                .fontWeight(.bold)
                VStack {
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
                .fontWidth(.expanded)
            }

            Spacer()

            HStack {
                Text("Txid".uppercased())
                    .foregroundColor(.secondary)
                Text(transaction.txid)
                    .lineLimit(1)
                    .truncationMode(.middle)
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
            .padding()

        }
        .padding()

    }
}

private let mockTransactionDetail =
    BitcoinDevKit.TransactionDetails(
        transaction: nil,
        fee: Optional(2820),
        received: 10_000_000,
        sent: 0,
        txid: "cdcc4d287e4780d25c577d4f5726c7d585625170559f0b294da20b55ffa2b009",
        confirmationTime: Optional(
            BitcoinDevKit.BlockTime(height: 178497, timestamp: 1_687_465_081)
        )
    )

#Preview{
    TransactionDetailsView(transaction: mockTransactionDetail, amount: UInt64(10_000_000))
}
