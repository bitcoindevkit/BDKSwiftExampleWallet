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
                    .padding(.top, 20.0)
                    .padding(.bottom, 20.0)
                    VStack {
                        HStack {
                            Text("Activity")
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
                            transactionDetails: viewModel.transactionDetails,
                            walletSyncState: viewModel.walletSyncState
                        )
                        .refreshable {
                            await viewModel.sync()
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
                        await viewModel.sync()
                        isFirstAppear = false
                        newTransactionSent = false
                    }
                    viewModel.getBalance()
                    viewModel.getTransactions()
                    await viewModel.getPrices()
                }

            }
            .toolbar {
                ToolbarItem {
                    NavigationLink(destination: SettingsView(viewModel: .init())) {
                        Image(systemName: "gear")
                            .foregroundStyle(.gray)
                    }
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

    #Preview("WalletView Zero - en") {
        WalletView(viewModel: .init(priceClient: .mockZero, bdkClient: .mockZero))
    }

    #Preview("WalletView Wait - en") {
        WalletView(viewModel: .init(priceClient: .mockPause, bdkClient: .mock))
    }

    #Preview("WalletView - fr") {
        WalletView(viewModel: .init(priceClient: .mock, bdkClient: .mock))
            .environment(\.locale, .init(identifier: "fr"))
    }
#endif
