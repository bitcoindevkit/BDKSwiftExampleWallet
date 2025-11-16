//
//  WalletView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 5/23/23.
//

import BitcoinUI
import SwiftUI

struct WalletView: View {
    @AppStorage("balanceDisplayFormat") private var balanceFormat: BalanceDisplayFormat =
        .bitcoinSats
    @AppStorage("KyotoLastBlockHeight") private var kyotoLastHeight: Int = 0
    @Bindable var viewModel: WalletViewModel
    @Binding var sendNavigationPath: NavigationPath
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

                BalanceView(
                    format: balanceFormat,
                    balance: viewModel.balanceTotal,
                    fiatPrice: viewModel.price
                ).onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        balanceFormat =
                            BalanceDisplayFormat.allCases[
                                (balanceFormat.index + 1) % BalanceDisplayFormat.allCases.count
                            ]
                    }
                }

                VStack {
                    ActivityHomeHeaderView(
                        walletSyncState: viewModel.walletSyncState,
                        progress: viewModel.progress,
                        inspectedScripts: viewModel.inspectedScripts,
                        totalScripts: viewModel.totalScripts,
                        needsFullScan: viewModel.needsFullScan,
                        isKyotoClient: viewModel.isKyotoClient,
                        isKyotoConnected: viewModel.isKyotoConnected,
                        currentBlockHeight: viewModel.currentBlockHeight
                    ) {
                        showAllTransactions = true
                    }

                    if shouldShowKyotoInitialSyncNotice {
                        KyotoInitialSyncNoticeView(isConnected: viewModel.isKyotoConnected)
                            .transition(.opacity)
                    }

                    TransactionListView(
                        viewModel: .init(),
                        transactions: viewModel.recentTransactions,
                        walletSyncState: viewModel.walletSyncState,
                        format: balanceFormat,
                        fiatPrice: viewModel.price
                    )
                    .refreshable {
                        if viewModel.isKyotoClient {
                            viewModel.getBalance()
                            viewModel.getTransactions()
                            await viewModel.getPrices()
                        } else {
                            await viewModel.syncOrFullScan()
                            viewModel.getBalance()
                            viewModel.getTransactions()
                            await viewModel.getPrices()
                        }
                    }

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
                        // Show cached state first
                        viewModel.getBalance()
                        viewModel.getTransactions()

                        // Then sync and refresh
                        await viewModel.syncOrFullScan()
                        viewModel.getBalance()
                        viewModel.getTransactions()
                        await viewModel.getPrices()
                    }
                }
            )
            .task {
                viewModel.getBalance()
                viewModel.getTransactions()
                if isFirstAppear || newTransactionSent {
                    await viewModel.syncOrFullScan()
                    isFirstAppear = false
                    newTransactionSent = false
                    viewModel.getBalance()
                    viewModel.getTransactions()
                }
                await viewModel.getPrices()
            }
            .onAppear {
                // Seed height from AppStorage on first show to avoid displaying 0 when Kyoto is active
                if viewModel.isKyotoClient,
                    viewModel.currentBlockHeight == 0,
                    kyotoLastHeight > 0
                {
                    viewModel.currentBlockHeight = UInt32(kyotoLastHeight)
                }
            }
            .onChange(of: viewModel.currentBlockHeight) { _, newValue in
                if newValue > 0 {
                    kyotoLastHeight = Int(newValue)
                }
            }

        }
        .navigationDestination(isPresented: $showAllTransactions) {
            ActivityListView(viewModel: .init(fiatPrice: viewModel.price))
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
                    Image(systemName: "ellipsis")
                }
            }

            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    showReceiveView = true
                } label: {
                    Image(systemName: "qrcode")
                }

                Spacer()

                Button {
                    sendNavigationPath.append(NavigationDestination.address)
                } label: {
                    Image(systemName: "qrcode.viewfinder")
                }
                .disabled(!viewModel.canSend)
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

extension WalletView {
    fileprivate var shouldShowKyotoInitialSyncNotice: Bool {
        viewModel.isKyotoClient
            && viewModel.needsFullScan
            && viewModel.walletSyncState == .syncing
    }
}

private struct KyotoInitialSyncNoticeView: View {
    let isConnected: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.title3)
                .foregroundStyle(.orange)

            VStack(alignment: .leading, spacing: 4) {
                Text(
                    "Keep Kyoto open while it bootstraps."
                )
                .font(.subheadline)
                .fontWeight(.semibold)

                Text(
                    "This one-time sync can take a few minutes."
                )
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
