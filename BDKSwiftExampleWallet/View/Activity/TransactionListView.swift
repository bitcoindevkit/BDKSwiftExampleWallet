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
    private let format: BalanceDisplayFormat
    private let fiatPrice: Double

    init(
        viewModel: TransactionListViewModel,
        transactions: [CanonicalTx],
        walletSyncState: WalletSyncState,
        format: BalanceDisplayFormat,
        fiatPrice: Double
    ) {
        self.viewModel = viewModel
        self.transactions = transactions
        self.walletSyncState = walletSyncState
        self.format = format
        self.fiatPrice = fiatPrice
    }

    var body: some View {

        List {
            if transactions.isEmpty && walletSyncState == .syncing {
                TransactionItemView(
                    txDetails: .mock,
                    isRedacted: true,
                    format: format,
                    fiatPrice: fiatPrice
                )
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            } else if transactions.isEmpty {

                VStack(alignment: .leading) {

                    Text("No Transactions")
                        .font(.subheadline)

                    let signetNetwork = Constants.Config.SignetNetwork.from(
                        esploraURL: viewModel.getEsploraURL()
                    )

                    if viewModel.getNetwork() != Network.testnet.description
                        && viewModel.getNetwork() != Network.testnet4.description
                    {
                        Button {
                            if let faucetURL = signetNetwork.defaultFaucet {
                                UIApplication.shared.open(faucetURL)
                            }
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

                    let testnet4FaucetURL = Constants.Networks.Testnet4.Faucet.mempool.url

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
                                txDetails: txDetails,
                                fiatPrice: fiatPrice
                            )
                        ) {
                            TransactionItemView(
                                txDetails: txDetails,
                                isRedacted: false,
                                format: format,
                                fiatPrice: fiatPrice
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
            walletSyncState: .synced,
            format: .bip177,
            fiatPrice: 714.23
        )
    }
    #Preview {
        TransactionListView(
            viewModel: .init(
                bdkClient: .mock
            ),
            transactions: [],
            walletSyncState: .synced,
            format: .bip177,
            fiatPrice: 714.23
        )
    }
#endif
