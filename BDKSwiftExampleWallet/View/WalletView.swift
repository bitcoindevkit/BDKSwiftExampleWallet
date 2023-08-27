//
//  WalletView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 5/23/23.
//

import SwiftUI
import WalletUI

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
                            .foregroundColor(.secondary)
                            .scaleEffect(isAnimating ? 1.0 : 0.6)
                            .onAppear {
                                withAnimation(.easeOut(duration: 0.5)) {
                                    isAnimating = true
                                }
                            }
                        HStack(spacing: 15) {
                            Image(systemName: "bitcoinsign")
                                .foregroundColor(.secondary)
                                .font(.title)
                            Text(viewModel.balanceTotal.formattedSatoshis())
                            Text("sats")
                                .foregroundColor(.secondary)
                        }
                        .font(.largeTitle)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        HStack {
                            if viewModel.walletSyncState == .syncing {
                                Image(systemName: "chart.bar.fill")
                                    .symbolEffect(
                                        .variableColor.cumulative
                                    )
                            }
                            withAnimation {
                                if let satsPrice = viewModel.satsPrice {
                                    Text(satsPrice)
                                } else {
                                    Text("$")
                                }
                            }
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
                                                viewModel.walletSyncState == .synced ?
                                                    .green :
                                                        .secondary
                                            )
                                    } else {
                                        Image(systemName: "questionmark")
                                    }
                                    Text(viewModel.walletSyncState.description)
                                        .foregroundColor(
                                            viewModel.walletSyncState == .synced ?
                                                .green :
                                                    .secondary
                                        )
                                }
                            }
                            .foregroundColor(.secondary)
                            .font(.caption)
                        }
                        if viewModel.transactionDetails.isEmpty {
                            Text("No Transactions")
                        } else {
                            WalletTransactionListView(transactionDetails: viewModel.transactionDetails)
                                .refreshable {
                                    await viewModel.sync()
                                    // TODO: call 3 other functions here too?
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

#Preview("WalletView - en") {
    WalletView(viewModel: .init(priceService: .mock, bdkService: .mock))
}

#Preview("WalletView Zero - en") {
    WalletView(viewModel: .init(priceService: .mockZero, bdkService: .mockZero))
}

#Preview("WalletView Wait - en") {
    WalletView(viewModel: .init(priceService: .mockPause, bdkService: .mock))
}

#Preview("WalletView - fr") {
    WalletView(viewModel: .init(priceService: .mock, bdkService: .mock))
        .environment(\.locale, .init(identifier: "fr"))
}
