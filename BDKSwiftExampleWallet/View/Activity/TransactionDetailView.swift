//
//  TransactionDetailView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 6/22/23.
//

import BitcoinDevKit
import BitcoinUI
import SwiftUI

struct TransactionDetailView: View {
    @Bindable var viewModel: TransactionDetailViewModel
    @State private var isCopied = false
    @State private var showCheckmark = false
    let amount: UInt64
    let canonicalTx: CanonicalTx

    var body: some View {

        VStack {

            VStack(spacing: 8) {
                HStack(spacing: 3) {
                    let sentAndReceivedValues = viewModel.getSentAndReceived(
                        tx: canonicalTx.transaction
                    )
                    if let value = sentAndReceivedValues {
                        let sent = value.sent
                        let received = value.received
                        if sent.toSat() == 0 && received.toSat() > 0 {
                            VStack {
                                Image("bitcoinsign.arrow.down")
                                    .symbolRenderingMode(.hierarchical)
                                    .font(.title)
                                Text("Receive")
                            }
                        } else if sent.toSat() > 0 && received.toSat() >= 0 {
                            VStack {
                                Image("bitcoinsign.arrow.up")
                                    .symbolRenderingMode(.hierarchical)
                                    .font(.title)
                                Text("Send")
                            }
                        } else {
                            Text("?")
                        }
                    }
                }
                .fontWeight(.semibold)

                switch canonicalTx.chainPosition {
                case .confirmed(let confirmationBlockTime):
                    Text("Block \(confirmationBlockTime.blockId.height.delimiter)")
                        .foregroundStyle(.secondary)
                case .unconfirmed(_):
                    Text("Unconfirmed")
                        .foregroundStyle(.secondary)
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
                .foregroundStyle(.primary)
                .fontWeight(.bold)
                .fontDesign(.rounded)
                VStack(spacing: 4) {
                    switch canonicalTx.chainPosition {
                    case .confirmed(let confirmationBlockTime):
                        Text(
                            confirmationBlockTime.confirmationTime.toDate().formatted(
                                date: .abbreviated,
                                time: Date.FormatStyle.TimeStyle.shortened
                            )
                        )
                    case .unconfirmed(let timestamp):
                        Text(
                            timestamp.toDate().formatted(
                                date: .abbreviated,
                                time: Date.FormatStyle.TimeStyle.shortened
                            )
                        )
                    }
                    if let fee = viewModel.calculateFee {
                        Text("\(fee.formattedWithSeparator) sats fee")
                    }
                }
                .foregroundStyle(.secondary)
                .font(.callout)
            }

            Spacer()

            HStack {
                if viewModel.network != Network.regtest.description {
                    Button {
                        if let esploraURL = viewModel.esploraURL {
                            let urlString =
                                "\(esploraURL)/tx/\(canonicalTx.transaction.computeTxid())"
                                .replacingOccurrences(of: "/api", with: "")
                            if let url = URL(string: urlString) {
                                UIApplication.shared.open(url)
                            }
                        }
                    } label: {
                        Image(systemName: "safari")
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                    }
                    Spacer()
                }
                Button {
                    UIPasteboard.general.string = canonicalTx.transaction.computeTxid()
                    isCopied = true
                    showCheckmark = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        isCopied = false
                        showCheckmark = false
                    }
                } label: {
                    HStack {
                        Text(canonicalTx.transaction.computeTxid())
                            .lineLimit(1)
                            .truncationMode(.middle)
                        withAnimation {
                            Image(
                                systemName: showCheckmark
                                    ? "document.on.document.fill" : "document.on.document"
                            )
                            .contentTransition(.symbolEffect(.replace))
                        }
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                }
            }
            .fontDesign(.monospaced)
            .font(.caption)
            .padding()
            .task {
                viewModel.getNetwork()
                viewModel.getEsploraUrl()
                viewModel.getCalulateFee(tx: canonicalTx.transaction)
            }

        }
        .padding()
        .padding(.top, 40.0)
        .alert(isPresented: $viewModel.showingTransactionDetailsViewErrorAlert) {
            Alert(
                title: Text("Transaction Details Error"),
                message: Text(viewModel.transactionDetailsError?.description ?? "Unknown"),
                dismissButton: .default(Text("OK")) {
                    viewModel.transactionDetailsError = nil
                }
            )
        }

    }
}

#if DEBUG
    #Preview {
        TransactionDetailView(
            viewModel: .init(
                bdkClient: .mock  //,
                    //                keyClient: .mock
            ),
            amount: UInt64(1_000_000),
            canonicalTx: .mock
        )
    }
#endif
