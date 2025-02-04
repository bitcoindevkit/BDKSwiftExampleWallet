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
    @AppStorage("balanceDisplayFormat") private var balanceFormat: BalanceDisplayFormat =
        .bitcoinSats
    @Bindable var viewModel: WalletViewModel
    @Binding var sendNavigationPath: NavigationPath
    @State private var balanceTextPulsingOpacity: Double = 0.7
    @State private var isFirstAppear = true
    @State private var newTransactionSent = false
    @State private var showAllTransactions = false
    @State private var showReceiveView = false
    @State private var showSettingsView = false
    @State private var showingFormatMenu = false

    var body: some View {

        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 20) {

                VStack(spacing: 10) {
                    HStack(spacing: 15) {
                        currencySymbol
                        balanceText
                        unitText
                    }
                    .font(.largeTitle)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                }
                .accessibilityLabel("Bitcoin Balance")
                .accessibilityValue(formattedBalance)
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        balanceFormat =
                            BalanceDisplayFormat.allCases[
                                (balanceFormat.index + 1) % BalanceDisplayFormat.allCases.count
                            ]
                    }
                }
                .swipeGesture { direction in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        switch direction {
                        case .left:
                            balanceFormat =
                                BalanceDisplayFormat.allCases[
                                    (balanceFormat.index + 1) % BalanceDisplayFormat.allCases.count
                                ]
                        case .right:
                            balanceFormat =
                                BalanceDisplayFormat.allCases[
                                    (balanceFormat.index - 1 + BalanceDisplayFormat.allCases.count)
                                        % BalanceDisplayFormat.allCases.count
                                ]
                        }
                    }
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
                                .foregroundStyle(viewModel.canSend ? .primary : .secondary)
                        }
                        .disabled(!viewModel.canSend)
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

extension WalletView {

    @MainActor
    var formattedBalance: String {
        switch balanceFormat {
        case .sats:
            return viewModel.balanceTotal.formatted(.number)
        case .bitcoinSats:
            return viewModel.balanceTotal.formattedSatoshis()
        case .bitcoin:
            return String(format: "%.8f", Double(viewModel.balanceTotal) / 100_000_000)
        case .fiat:
            return viewModel.satsPrice.formatted(.number.precision(.fractionLength(2)))
        }
    }

    private var currencySymbol: some View {
        Image(systemName: balanceFormat == .fiat ? "dollarsign" : "bitcoinsign")
            .foregroundStyle(.secondary)
            .font(.title)
            .fontWeight(.thin)
            .transition(
                .asymmetric(
                    insertion: .move(edge: .leading).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)
                )
            )
            .opacity(balanceFormat == .sats ? 0 : 1)
            .id("symbol-\(balanceFormat)")
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: balanceFormat)
    }

    @MainActor
    var balanceText: some View {
        Text(balanceFormat == .fiat && viewModel.satsPrice == 0 ? "00.00" : formattedBalance)
            .contentTransition(.numericText(countsDown: true))
            .fontWeight(.semibold)
            .fontDesign(.rounded)
            .foregroundStyle(
                balanceFormat == .fiat && viewModel.satsPrice == 0 ? .secondary : .primary
            )
            .opacity(
                balanceFormat == .fiat && viewModel.satsPrice == 0 ? balanceTextPulsingOpacity : 1
            )
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: balanceFormat)
            .animation(.easeInOut, value: viewModel.satsPrice)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    balanceTextPulsingOpacity = 0.3
                }
            }
    }

    private var unitText: some View {
        Text(balanceFormat.displayText)
            .foregroundStyle(.secondary)
            .fontWeight(.thin)
            .transition(
                .asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                )
            )
            .id("format-\(balanceFormat)")
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: balanceFormat)
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
