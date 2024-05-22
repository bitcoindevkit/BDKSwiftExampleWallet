//
//  WalletView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 5/23/23.
//

import BitcoinDevKit
import BitcoinUI
import SwiftUI

struct WalletView: View {
    @Bindable var viewModel: WalletViewModel
    @State private var isAnimating: Bool = false
    @State private var isFirstAppear = true
    @State private var newTransactionSent = false

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
                            .foregroundColor(.bitcoinOrange)
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
                                VStack {

                                    Image(systemName: "chart.bar.fill")
                                        .symbolEffect(
                                            .variableColor.cumulative
                                        )

                                    ProgressView(value: viewModel.progress) {
                                        Text("Progress")
                                    } currentValueLabel: {
                                        Text(
                                            "Current Progress: \(String(format: "%.0f%%", viewModel.progress * 100))"
                                        )
                                    }
                                    .progressViewStyle(.circular)
                                    .tint(.bitcoinOrange)

                                    HStack {
                                        ProgressView(value: viewModel.progress)
                                            .progressViewStyle(CircularProgressViewStyle())
                                            .frame(width: 50, height: 50)

                                        VStack(alignment: .leading) {
                                            Text("Inspected: \(viewModel.inspectedScripts)")
                                            Text("Total: \(viewModel.totalScripts)")
                                            Text(
                                                String(
                                                    format: "Progress: %.2f%%",
                                                    viewModel.progress * 100
                                                )
                                            )
                                        }
                                    }

                                }
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
                            Text("\(viewModel.transactions.count) Transactions")
                                .fontWeight(.thin)
                                .font(.caption2)
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
                        .fontWeight(.bold)
                        WalletTransactionListView(
                            transactions: viewModel.transactions,
                            walletSyncState: viewModel.walletSyncState,
                            viewModel: .init()
                        )
                        .refreshable {
                            await viewModel.syncOrFullScan()
                            viewModel.getBalance()
                            viewModel.getTransactions()
                            await viewModel.getPrices()
                        }
                        Spacer()
                    }

                }
                .padding()
                .onReceive(
                    NotificationCenter.default.publisher(for: Notification.Name("TransactionSent")),
                    perform: { _ in
                        newTransactionSent = true
                    }
                )
                .task {
                    if isFirstAppear || newTransactionSent {
                        await viewModel.syncOrFullScan()
                        isFirstAppear = false
                        newTransactionSent = false
                    }
                    viewModel.getBalance()
                    viewModel.getTransactions()
                    await viewModel.getPrices()
                }

            }

        }
        .alert(isPresented: $viewModel.showingWalletViewErrorAlert) {
            Alert(
                title: Text("Wallet Error"),
                message: Text(viewModel.walletViewError?.description ?? "Unknown"),
                dismissButton: .default(Text("OK")) {
                    viewModel.walletViewError = nil
                }
            )
        }

    }

}

#if DEBUG
    #Preview("WalletView - en") {
        WalletView(viewModel: .init(priceClient: .mock, bdkClient: .mock))
    }

    #Preview("WalletView - en - Large") {
        WalletView(viewModel: .init(priceClient: .mock, bdkClient: .mock))
            .environment(\.sizeCategory, .accessibilityLarge)
    }

    #Preview("WalletView Wait - en") {
        WalletView(viewModel: .init(priceClient: .mockPause, bdkClient: .mock))
    }

    #Preview("WalletView - fr") {
        WalletView(viewModel: .init(priceClient: .mock, bdkClient: .mock))
            .environment(\.locale, .init(identifier: "fr"))
    }
#endif
