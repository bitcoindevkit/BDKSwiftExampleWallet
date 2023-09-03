//
//  WalletView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 5/23/23.
//

import BitcoinUI
import SwiftUI

struct WalletView: View {
    @Bindable var viewModel: WalletViewModel
    @State private var isAnimating: Bool = false
    @State private var isFirstAppear = true

    var body: some View {

        NavigationView {

            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 20) {

                    VStack(spacing: 10) {
                        Text("Bitcoin".uppercased())
                            .fontWeight(.semibold)
                            .fontWidth(.expanded)
                            .foregroundColor(.orange)
                            .scaleEffect(isAnimating ? 1.0 : 0.6)
                            .onAppear {
                                withAnimation(.easeOut(duration: 0.5)) {
                                    isAnimating = true
                                }
                            }
                        withAnimation {
                            HStack(spacing: 15) {
                                Image(systemName: "bitcoinsign")
                                    .foregroundColor(.secondary)
                                    .font(.title)
                                    .fontWeight(.thin)
                                Text(viewModel.balanceTotal.formattedSatoshis())
                                    .contentTransition(.numericText())
                                    .fontWeight(.semibold)
                                    .fontDesign(.rounded)
                                Text("sats")
                                    .foregroundColor(.secondary)
                                    .fontWeight(.thin)
                            }
                            .font(.largeTitle)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        }
                        HStack {
                            if viewModel.walletSyncState == .syncing {
                                Image(systemName: "chart.bar.fill")
                                    .symbolEffect(
                                        .variableColor.cumulative
                                    )
                            }
                            Text(viewModel.satsPrice)
                                .contentTransition(.numericText())
                                .fontDesign(.rounded)
                        }
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                    }
                    .padding(.top, 40.0)
                    .padding(.bottom, 20.0)
                    VStack {
                        HStack {
                            Text("Activity")
                                .bold()
                            Spacer()
                            HStack {
                                HStack(spacing: 5) {
                                    if viewModel.walletSyncState == .syncing {
                                        Image(systemName: "slowmo")
                                            .symbolEffect(
                                                .variableColor.cumulative
                                            )
                                            .contentTransition(.symbolEffect(.replace.offUp))
                                    } else if viewModel.walletSyncState == .synced {
                                        Image(systemName: "checkmark.circle")
                                            .foregroundColor(
                                                viewModel.walletSyncState == .synced
                                                    ? .green : .secondary
                                            )
                                    } else {
                                        Image(systemName: "questionmark")
                                    }
                                }
                            }
                            .foregroundColor(.secondary)
                            .font(.caption)
                        }
                        if viewModel.transactionDetails.isEmpty
                            && viewModel.walletSyncState == .syncing
                        {
                            Text("")
                        } else if viewModel.transactionDetails.isEmpty {
                            Text("No Transactions")
                        } else {
                            WalletTransactionListView(
                                transactionDetails: viewModel.transactionDetails
                            )
                            .refreshable {
                                await viewModel.sync()
                                viewModel.getBalance()
                                viewModel.getTransactions()
                                await viewModel.getPrices()
                            }
                        }
                        Spacer()
                    }

                }
                .padding()
                .task {
                    if isFirstAppear {
                        await viewModel.sync()
                        isFirstAppear = false
                    }
                    viewModel.getBalance()
                    viewModel.getTransactions()
                    await viewModel.getPrices()
                }
            }

        }

    }

}

#Preview("WalletView - en"){
    WalletView(viewModel: .init(priceClient: .mock, bdkClient: .mock))
}

#Preview("WalletView Zero - en"){
    WalletView(viewModel: .init(priceClient: .mockZero, bdkClient: .mockZero))
}

#Preview("WalletView Wait - en"){
    WalletView(viewModel: .init(priceClient: .mockPause, bdkClient: .mock))
}

#Preview("WalletView - fr"){
    WalletView(viewModel: .init(priceClient: .mock, bdkClient: .mock))
        .environment(\.locale, .init(identifier: "fr"))
}
