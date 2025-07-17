//
//  TransactionListView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/6/23.
//

import BitcoinDevKit
import BitcoinUI
import SwiftUI

struct TransactionListView: View {
    @Bindable var viewModel: TransactionListViewModel
    let transactions: [CanonicalTx]
    let walletSyncState: WalletSyncState

    var body: some View {

        List {
            if transactions.isEmpty && walletSyncState == .syncing {
                TransactionItemView(
                    txDetails: .mock,
                    isRedacted: true
                )
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            } else if transactions.isEmpty {

                VStack(alignment: .leading) {

                    Text("No Transactions")
                        .font(.subheadline)

                    let mutinyFaucetURL = URL(string: "https://faucet.mutinynet.com")
                    let signetFaucetURL = URL(string: "https://signetfaucet.com")

                    if let mutinyFaucetURL,
                        let signetFaucetURL,
                        viewModel.getNetwork() != Network.testnet.description
                            && viewModel.getNetwork() != Network.testnet4.description
                    {
                        Button {
                            UIApplication.shared.open(
                                viewModel.getEsploraURL()
                                    == Constants.Config.EsploraServerURLNetwork.Signet.mutiny
                                    ? mutinyFaucetURL : signetFaucetURL
                            )
                        } label: {
                            HStack(spacing: 2) {
                                Text("Get sats from faucet")
                                Image(systemName: "arrow.right")
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .underline()
                        }
                        .buttonStyle(.plain)
                    }

                    let testnet4FaucetURL = URL(string: "https://mempool.space/testnet4/faucet")

                    if let testnet4FaucetURL,
                        viewModel.getNetwork() == Network.testnet4.description
                    {
                        Button {
                            UIApplication.shared.open(
                                testnet4FaucetURL
                            )
                        } label: {
                            HStack(spacing: 2) {
                                Text("Get sats from faucet")
                                Image(systemName: "arrow.right")
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .underline()
                        }
                        .buttonStyle(.plain)
                    }

                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)

            } else {

                ForEach(
                    transactions,
                    id: \.transaction.transactionID
                ) { item in
                    let canonicalTx = item
                    let tx = canonicalTx.transaction
                    if let txDetails = viewModel.getTxDetails(txid: tx.computeTxid()) {

                        NavigationLink(
                            destination: TransactionDetailView(
                                viewModel: .init(
                                    bdkClient: .live
                                ),
                                txDetails: txDetails
                            )
                        ) {
                            TransactionItemView(
                                txDetails: txDetails,
                                isRedacted: false
                            )
                        }

                    } else {
                        Image(systemName: "questionmark")
                    }

                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

            }

        }
        .listStyle(.plain)
        .alert(isPresented: $viewModel.showingWalletTransactionsViewErrorAlert) {
            Alert(
                title: Text("Wallet Transaction Error"),
                message: Text(viewModel.walletTransactionsViewError?.description ?? "Unknown"),
                dismissButton: .default(Text("OK")) {
                    viewModel.walletTransactionsViewError = nil
                }
            )
        }

    }

}

#if DEBUG
    #Preview {
        TransactionListView(
            viewModel: .init(
                bdkClient: .mock
            ),
            transactions: [
                .mock
            ],
            walletSyncState: .synced
        )
    }
    #Preview {
        TransactionListView(
            viewModel: .init(
                bdkClient: .mock
            ),
            transactions: [],
            walletSyncState: .synced
        )
    }
#endif
