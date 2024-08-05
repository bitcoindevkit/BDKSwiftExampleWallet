//
//  ActivityListView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/4/24.
//

import BitcoinDevKit
import SwiftUI

struct ActivityListView: View {
    @Bindable var viewModel: ActivityListViewModel

    var body: some View {

        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                CustomSegmentedControl(selection: $viewModel.displayMode)
                    .padding(.vertical)

                if viewModel.displayMode == .transactions {
                    TransactionListView(
                        transactions: viewModel.transactions,
                        walletSyncState: viewModel.walletSyncState,
                        viewModel: .init()
                    )
                } else {
                    LocalOutputListView(
                        localOutputs: viewModel.utxos,
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
    @Binding var selection: ActivityListViewModel.DisplayMode

    var body: some View {
        HStack(spacing: 20) {
            segmentButton(for: .transactions)
            segmentButton(for: .utxos)
            Spacer()
        }
    }

    private func segmentButton(for mode: ActivityListViewModel.DisplayMode) -> some View {
        Button(action: {
            selection = mode
        }) {
            Text(mode == .transactions ? "Transactions" : "UTXOs").bold()
                .foregroundColor(selection == mode ? .primary : .gray)
        }
    }
}

#Preview {
    ActivityListView(viewModel: .init())
}
