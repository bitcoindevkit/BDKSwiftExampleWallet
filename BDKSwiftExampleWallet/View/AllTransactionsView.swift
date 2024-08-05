//
//  AllTransactionsView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/4/24.
//

import BitcoinDevKit
import SwiftUI

struct AllTransactionsView: View {
    @Bindable var viewModel: AllTransactionsViewModel

    var body: some View {

        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                CustomSegmentedControl(selection: $viewModel.displayMode)
                    .padding(.vertical)

                if viewModel.displayMode == .transactions {
                    WalletTransactionListView(
                        transactions: viewModel.transactions,
                        walletSyncState: viewModel.walletSyncState,
                        viewModel: .init()
                    )
                } else {
                    UTXOListView(
                        utxos: viewModel.utxos,
                        walletSyncState: viewModel.walletSyncState
                    )
                }
            }
            .task {
                viewModel.getTransactions()
                viewModel.getUTXOs()
            }
        }
        .navigationTitle(
            viewModel.displayMode == .transactions
                ? "\(viewModel.transactions.count) Transaction\(viewModel.transactions.count == 1 ? "" : "s")"
                : "\(viewModel.utxos.count) UTXO\(viewModel.utxos.count == 1 ? "" : "s")"
        )
        .navigationBarTitleDisplayMode(.inline)
        .padding(.top)
        .padding()

    }

}

struct CustomSegmentedControl: View {
    @Binding var selection: AllTransactionsViewModel.DisplayMode

    var body: some View {
        HStack(spacing: 20) {
            segmentButton(for: .transactions)
            segmentButton(for: .utxos)
            Spacer()
        }
    }

    private func segmentButton(for mode: AllTransactionsViewModel.DisplayMode) -> some View {
        Button(action: {
            selection = mode
        }) {
            Text(mode == .transactions ? "Transactions" : "UTXOs").bold()
                .foregroundColor(selection == mode ? .primary : .gray)
        }
    }
}

#Preview {
    AllTransactionsView(viewModel: .init())
}
