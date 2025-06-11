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
    let txDetails: TxDetails

    var body: some View {

        VStack {

            VStack(spacing: 8) {
                HStack(spacing: 3) {
                    if txDetails.balanceDelta >= 0 {
                        VStack {
                            Image("bitcoinsign.arrow.down")
                                .symbolRenderingMode(.hierarchical)
                                .font(.title)
                            Text("Receive")
                        }
                    } else {
                        VStack {
                            Image("bitcoinsign.arrow.up")
                                .symbolRenderingMode(.hierarchical)
                                .font(.title)
                            Text("Send")
                        }
                    }
                }
                .fontWeight(.semibold)

                switch txDetails.chainPosition {
                case .confirmed(let confirmationBlockTime, _):
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
                    Text(abs(txDetails.balanceDelta).delimiter)
                    Text("sats")
                }
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .font(.largeTitle)
                .foregroundStyle(.primary)
                .fontWeight(.bold)
                .fontDesign(.rounded)
                VStack(spacing: 4) {
                    switch txDetails.chainPosition {
                    case .confirmed(let confirmationBlockTime, _):
                        Text(
                            confirmationBlockTime.confirmationTime.toDate().formatted(
                                date: .abbreviated,
                                time: Date.FormatStyle.TimeStyle.shortened
                            )
                        )
                    case .unconfirmed(let timestamp):
                        if let timestamp {
                            Text(
                                timestamp.toDate().formatted(
                                    date: .abbreviated,
                                    time: Date.FormatStyle.TimeStyle.shortened
                                )
                            )
                        } else {
                            Text("Pending")
                        }
                    }
                    if let fee = txDetails.fee {
                        Text("\(fee.toSat().delimiter) sats fee")
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
                                "\(esploraURL)/tx/\(txDetails.txid)"
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
                    UIPasteboard.general.string = "\(txDetails.txid)"
                    isCopied = true
                    showCheckmark = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        isCopied = false
                        showCheckmark = false
                    }
                } label: {
                    HStack {
                        Text("\(txDetails.txid)")
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
                bdkClient: .mock
            ),
            txDetails: .mock
        )
    }
#endif
