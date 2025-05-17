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
                        needsFullScan: viewModel.needsFullScan
                    ) {
                        showAllTransactions = true
                    }
                    
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

//#if DEBUG
//    #Preview("WalletView - en") {
//        WalletView(
//            viewModel: .init(
//                bdkClient: .mock,
//                priceClient: .mock,
//                transactions: [.mock],
//                walletSyncState: .synced
//            ),
//            sendNavigationPath: .constant(.init())
//        )
//    }
//#endif
