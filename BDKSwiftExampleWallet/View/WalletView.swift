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
                        Text("Your Balance".uppercased())
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
                        VStack {
                            HStack {
                                Text(viewModel.satsPrice)
                                if let time = viewModel.time?.newDateAgo() {
                                    Text(time)
                                }
                            }
                            HStack {
                                HStack(spacing: 5) {
                                    Text(viewModel.walletSyncState.description)
                                    if viewModel.walletSyncState == .syncing {
                                        ProgressView()
                                    }
                                }
                                if let lastSyncTime = viewModel.lastSyncTime {
                                    Text(lastSyncTime.formattedSyncTime())
                                        .font(.caption)
                                }
                            }
                            
                        }
                        .foregroundColor(.secondary)
                        .font(.footnote)
                        .padding(.top, 10.0)
                    }
                    .padding(.top, 40.0)
                    
                    VStack {
                        HStack {
                            Text("Activity")
                                .bold()
                            Spacer()
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
    WalletView(viewModel: .init(priceService: .init()))
}

#Preview("WalletView - fr") {
    WalletView(viewModel: .init(priceService: .init()))
        .environment(\.locale, .init(identifier: "fr"))
}
