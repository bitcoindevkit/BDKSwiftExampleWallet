//
//  ActivityListView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/4/24.
//

import BitcoinDevKit
import SwiftUI

struct ActivityListView: View {
    @AppStorage("balanceDisplayFormat") private var balanceFormat: BalanceDisplayFormat =
        .bitcoinSats
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
                        viewModel: .init(),
                        transactions: viewModel.transactions,
                        walletSyncState: viewModel.walletSyncState,
                        format: balanceFormat,
                        fiatPrice: viewModel.fiatPrice
                    )
                    .transition(.blurReplace)
                } else {
                    LocalOutputListView(
                        localOutputs: viewModel.localOutputs,
                        walletSyncState: viewModel.walletSyncState
                    )
                    .transition(.blurReplace)
                }
            }
            .task {
                viewModel.getTransactions()
                viewModel.listUnspent()
            }
        }
        .navigationTitle(
            viewModel.displayMode == .transactions
                ? "\(viewModel.transactions.count) Transaction\(viewModel.transactions.count == 1 ? "" : "s")"
                : "\(viewModel.localOutputs.count) Output\(viewModel.localOutputs.count == 1 ? "" : "s")"
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
            segmentButton(for: .outputs)
            Spacer()
        }
    }

    private func segmentButton(for mode: ActivityListViewModel.DisplayMode) -> some View {
        Button {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                selection = mode
            }
        } label: {
            Text(mode == .transactions ? "Transactions" : "Unspent")
                .bold()
                .foregroundStyle(selection == mode ? Color.primary : Color.gray)
        }
    }
}

#Preview {
    ActivityListView(viewModel: .init(fiatPrice: 714.23))
}
