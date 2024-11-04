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
    @Binding var sendNavigationPath: NavigationPath
    @State private var isFirstAppear = true
    @State private var newTransactionSent = false
    @State private var showAllTransactions = false
    @State private var showReceiveView = false
    @State private var showSettingsView = false

    var body: some View {

        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 20) {

                VStack(spacing: 10) {
                    withAnimation {
                        HStack(spacing: 15) {
                            Image(systemName: "bitcoinsign")
                                .foregroundStyle(.secondary)
                                .font(.title)
                                .fontWeight(.thin)
                            Text(viewModel.balanceTotal.formattedSatoshis())
                                .contentTransition(.numericText())
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                            Text("sats")
                                .foregroundStyle(.secondary)
                                .fontWeight(.thin)
                        }
                        .font(.largeTitle)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    }
                    .accessibilityLabel("Bitcoin Balance")
                    .accessibilityValue("\(viewModel.balanceTotal.formattedSatoshis()) sats")
                    HStack {
                        if viewModel.walletSyncState == .syncing {
                            Image(systemName: "chart.bar.fill")
                                .symbolEffect(.variableColor.cumulative)
                                .transition(.symbolEffect(.appear))
                        }
                        Text(
                            viewModel.satsPrice > 0 || viewModel.walletSyncState == .synced
                                ? viewModel.satsPrice.formatted(.currency(code: "USD")) : ""
                        )
                        .fontDesign(.rounded)
                        .foregroundStyle(
                            viewModel.walletSyncState == .synced ? .secondary : .tertiary
                        )
                        .opacity(
                            viewModel.walletSyncState == .syncing && viewModel.satsPrice == 0
                                ? 0.7 : 1
                        )
                        .contentTransition(.numericText())
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.5),
                            value: viewModel.satsPrice
                        )
                    }
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.5),
                        value: viewModel.walletSyncState
                    )
                }
                .padding(.vertical, 35.0)

                VStack {
                    HStack {
                        Text("Activity")
                        Spacer()
                        if viewModel.walletSyncState == .syncing {
                            HStack {
                                if viewModel.progress < 1.0 {
                                    Text("\(viewModel.inspectedScripts)")
                                        .padding(.trailing, -5.0)
                                        .fontWeight(.semibold)
                                        .contentTransition(.numericText())
                                        .transition(.opacity)

                                    if !viewModel.bdkClient.needsFullScan() {
                                        Text("/")
                                            .padding(.trailing, -5.0)
                                            .transition(.opacity)
                                        Text("\(viewModel.totalScripts)")
                                            .contentTransition(.numericText())
                                            .transition(.opacity)
                                    }
                                }

                                if !viewModel.bdkClient.needsFullScan() {
                                    Text(
                                        String(
                                            format: "%.0f%%",
                                            viewModel.progress * 100
                                        )
                                    )
                                    .contentTransition(.numericText())
                                    .transition(.opacity)
                                }
                            }
                            .fontDesign(.monospaced)
                            .foregroundStyle(.secondary)
                            .font(.caption2)
                            .fontWeight(.thin)
                            .animation(.easeInOut, value: viewModel.inspectedScripts)
                            .animation(.easeInOut, value: viewModel.totalScripts)
                            .animation(.easeInOut, value: viewModel.progress)
                        }
                        HStack {
                            HStack(spacing: 5) {
                                if viewModel.walletSyncState == .syncing {
                                    Image(systemName: "slowmo")
                                        .symbolEffect(
                                            .variableColor.cumulative
                                        )
                                } else if viewModel.walletSyncState == .synced {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(
                                            viewModel.walletSyncState == .synced
                                                ? .green : .secondary
                                        )
                                } else if viewModel.walletSyncState == .notStarted {
                                    Image(systemName: "arrow.trianglehead.clockwise")
                                } else {
                                    Image(
                                        systemName: "person.crop.circle.badge.exclamationmark"
                                    )
                                }
                            }
                            .contentTransition(.symbolEffect(.replace.offUp))

                        }
                        .foregroundStyle(.secondary)
                        .font(.caption)

                        if viewModel.walletSyncState == .synced {
                            Button {
                                showAllTransactions = true
                            } label: {
                                HStack(spacing: 2) {
                                    Text("Show All")
                                    Image(systemName: "arrow.right")
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fontWeight(.regular)
                            }
                        }

                    }
                    .fontWeight(.bold)
                    TransactionListView(
                        viewModel: .init(),
                        transactions: viewModel.recentTransactions,
                        walletSyncState: viewModel.walletSyncState
                    )
                    .refreshable {
                        await viewModel.syncOrFullScan()
                        viewModel.getBalance()
                        viewModel.getTransactions()
                        await viewModel.getPrices()
                    }

                    HStack {
                        Button {
                            showReceiveView = true
                        } label: {
                            Image(systemName: "qrcode")
                                .font(.title)
                                .foregroundStyle(.primary)
                        }

                        Spacer()

                        NavigationLink(value: NavigationDestination.address) {
                            Image(systemName: "qrcode.viewfinder")
                                .font(.title)
                                .foregroundStyle(.primary)
                        }
                    }
                    .padding([.horizontal, .bottom])

                }

            }
            .padding()
            .onReceive(
                NotificationCenter.default.publisher(for: Notification.Name("TransactionSent")),
                perform: { _ in
                    newTransactionSent = true
                }
            )
            .onReceive(
                NotificationCenter.default.publisher(
                    for: Notification.Name("AddressGenerated")
                ),
                perform: { _ in
                    Task {
                        await viewModel.syncOrFullScan()
                        viewModel.getBalance()
                        viewModel.getTransactions()
                        await viewModel.getPrices()
                    }
                }
            )
            .task {
                viewModel.getBalance()
                if isFirstAppear || newTransactionSent {
                    await viewModel.syncOrFullScan()
                    isFirstAppear = false
                    newTransactionSent = false
                    viewModel.getBalance()
                }
                viewModel.getTransactions()
                await viewModel.getPrices()
            }

        }
        .navigationDestination(isPresented: $showAllTransactions) {
            ActivityListView(viewModel: .init())
        }
        .navigationDestination(for: NavigationDestination.self) { destination in
            switch destination {
            case .address:
                AddressView(navigationPath: $sendNavigationPath)
            case .amount(let address):
                AmountView(
                    viewModel: .init(),
                    navigationPath: $sendNavigationPath,
                    address: address
                )
            case .fee(let amount, let address):
                FeeView(
                    viewModel: .init(),
                    navigationPath: $sendNavigationPath,
                    address: address,
                    amount: amount
                )
            case .buildTransaction(let amount, let address, let fee):
                BuildTransactionView(
                    viewModel: .init(),
                    navigationPath: $sendNavigationPath,
                    address: address,
                    amount: amount,
                    fee: fee
                )
            }
        }
        .sheet(
            isPresented: $showReceiveView,
            onDismiss: {
                NotificationCenter.default.post(
                    name: Notification.Name("AddressGenerated"),
                    object: nil
                )
            }
        ) {
            ReceiveView(viewModel: .init())
        }
        .sheet(isPresented: $showSettingsView) {
            SettingsView(viewModel: .init())
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showSettingsView = true
                } label: {
                    Image(systemName: "person.and.background.dotted")
                }
            }
        }

    }

}

#if DEBUG
    #Preview("WalletView - en") {
        WalletView(
            viewModel: .init(
                bdkClient: .mock,
                priceClient: .mock,
                transactions: [.mock],
                walletSyncState: .synced
            ),
            sendNavigationPath: .constant(.init())
        )
    }
#endif
