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
    @ObservedObject var viewModel: TransactionDetailsViewModel

    let transaction: BitcoinDevKit.Transaction
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
                    let sentAndReceivedValues = viewModel.getSentAndReceived(tx: transaction)
                    if let value = sentAndReceivedValues {
                        let sent = value.sent
                        let received = value.received
                        if sent == 0 && received > 0 {
                            Text("Receive")
                        } else if sent > 0 && received >= 0 {
                            Text("Send")
                        } else {
                            Text("?")
                        }
                    }
                }
                .fontWeight(.semibold)
                Text("Block {Height}")
                    .foregroundColor(.secondary)
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
                    Text("{Confirmation Status / Timestamp}")
                    if let fee = viewModel.calculateFee {
                        Text("\(fee.formattedWithSeparator) sats fee")
                    }
                }
                .foregroundColor(.secondary)
                .font(.callout)
            }

            Spacer()

            HStack {
                if viewModel.network != Network.regtest.description {
                    Button {
                        if let esploraURL = viewModel.esploraURL {
                            let urlString = "\(esploraURL)/tx/\(transaction.txid())"
                                .replacingOccurrences(of: "/api", with: "")
                            if let url = URL(string: urlString) {
                                UIApplication.shared.open(url)
                            }
                        }
                    } label: {
                        Image(systemName: "safari")
                            .fontWeight(.semibold)
                            .foregroundColor(.bitcoinOrange)
                    }
                    Spacer()
                }
                Text(transaction.txid())
                    .lineLimit(1)
                    .truncationMode(.middle)
                Spacer()
                Button {
                    UIPasteboard.general.string = transaction.txid()
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
            .onAppear {
                viewModel.getNetwork()
                viewModel.getEsploraUrl()
                viewModel.getCalulateFee(tx: transaction)
            }

        }
        .padding()

    }
}

#if DEBUG
    #Preview {
        TransactionDetailsView(
            viewModel: .init(),
            transaction: mockTransaction1!,
            amount: UInt64(10_000_000)
        )
    }

    #Preview {
        TransactionDetailsView(
            viewModel: .init(),
            transaction: mockTransaction1!,
            amount: UInt64(10_000_000)
        )
        .environment(\.sizeCategory, .accessibilityLarge)
    }
#endif
