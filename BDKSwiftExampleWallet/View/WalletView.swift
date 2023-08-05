//
//  WalletView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 5/23/23.
//

import SwiftUI
import WalletUI
import BitcoinDevKit

class WalletViewModel: ObservableObject {
    
    // Balance
    @Published var balanceTotal: UInt64 = 0
    
    // Sync
    @Published var lastSyncTime: Date? = nil
    @Published var walletSyncState: WalletSyncState = .notStarted
    
    // Transactions
    @Published var transactionDetails: [TransactionDetails] = []
    
    // Price
    @Published var price: Double = 0.0
    @Published var time: Int?
    @Published var satsPrice: String = "0"
    let priceService: PriceService
    
    init(priceService: PriceService) {
        self.priceService = priceService
    }
    
    func getPrice() async {
        do {
            let response = try await priceService.hourlyPrice()
            if let latestPrice = response.prices.first?.usd {
                DispatchQueue.main.async {
                    self.price = latestPrice
                }
            }
            if let latestTime = response.prices.first?.time {
                DispatchQueue.main.async {
                    self.time = latestTime
                }
            }
        } catch {
            print("priceMem error: \(error.localizedDescription)")
        }
    }
    
    private func valueInUSD() {
        self.satsPrice = Double(balanceTotal).valueInUSD(price: price)
    }
    
    func getBalance() {
        do {
            let balance = try BDKService.shared.getBalance()
            self.balanceTotal = balance.total
        } catch let error as WalletError {
            print("getBalance - Wallet Error: \(error.localizedDescription)")
        } catch {
            print("getBalance - Undefined Error: \(error.localizedDescription)")
        }
    }
    
    func getTransactions() {
        do {
            let transactionDetails = try BDKService.shared.getTransactions()
            self.transactionDetails = transactionDetails
        } catch {
            print("getTransactions - none: \(error.localizedDescription)")
        }
    }
    
    func sync() async {
        DispatchQueue.main.async {
            self.walletSyncState = .syncing
        }
        Task {
            do {
                try await BDKService.shared.sync()
                DispatchQueue.main.async {
                    self.walletSyncState = .synced
                    self.lastSyncTime = Date()
                    self.getBalance()
                    self.getTransactions()
                    self.valueInUSD()
                }
            } catch {
                DispatchQueue.main.async {
                    self.walletSyncState = .error(error)
                }
            }
        }
    }
    
}

extension WalletViewModel {
    enum WalletSyncState: CustomStringConvertible, Equatable {
        case error(Error)
        case notStarted
        case synced
        case syncing
        
        var description: String {
            switch self {
            case .error(let error):
                return "Error Syncing: \(error.localizedDescription)"
            case .notStarted:
                return "Not Started"
            case .synced:
                return "Synced"
            case .syncing:
                return "Syncing"
            }
        }
        
        static func ==(lhs: WalletSyncState, rhs: WalletSyncState) -> Bool {
            switch (lhs, rhs) {
            case (.error(let error1), .error(let error2)):
                return error1.localizedDescription == error2.localizedDescription
            case (.notStarted, .notStarted):
                return true
            case (.synced, .synced):
                return true
            case (.syncing, .syncing):
                return true
            default:
                return false
            }
        }
    }
}

struct WalletView: View {
    @ObservedObject var viewModel: WalletViewModel
    @State private var isAnimating: Bool = false

    var body: some View {
        
        NavigationView {
            
            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    
                    VStack(spacing: 10) {
                        Text("Your Balance")
                            .bold()
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
                            Text(viewModel.satsPrice)
                            if let time = viewModel.time?.newDateAgo() {
                                Text(time)
                            }
                        }
                        .foregroundColor(.secondary)
                        .font(.footnote)
                        .padding(.top, 10.0)
                    }
                    
                    VStack {
                        HStack {
                            Text("Activity")
                                .bold()
                            Spacer()
                        }
                        if viewModel.transactionDetails.isEmpty {
                            Text("No Transactions")
                        } else {
                            List {
                                ForEach(
                                    viewModel.transactionDetails.sorted(
                                        by: {
                                            $0.confirmationTime?.timestamp ?? $0.received > $1.confirmationTime?.timestamp ?? $1.received
                                        }
                                    ),
                                    id: \.txid
                                ) { transaction in
                                    
                                    NavigationLink(
                                        destination: TransactionDetailsView(
                                            transaction: transaction,
                                            amount:
                                                transaction.sent > 0 ?
                                            transaction.sent - transaction.received :
                                                transaction.received - transaction.sent
                                        )
                                    ) {
                                        HStack {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.gray.opacity(0.2))
                                                    .frame(width: 40, height: 40)
                                                Image(systemName:
                                                        transaction.sent > 0 ?
                                                      "arrow.up" :
                                                        "arrow.down"
                                                )
                                                .frame(width: 20, height: 20)
                                            }
                                            VStack(alignment: .leading, spacing: 1){
                                                Text(transaction.txid)
                                                    .truncationMode(.middle)
                                                    .lineLimit(1)
                                                Text(
                                                    transaction.sent > 0 ?
                                                    "Sent" :
                                                        "Received"
                                                )
                                                .foregroundColor(.secondary)
                                            }
                                            .padding(.trailing, 40.0)
                                            Spacer()
                                            Text(
                                                transaction.sent > 0 ?
                                                "- \(transaction.sent - transaction.received) sats" :
                                                    "+ \(transaction.received - transaction.sent) sats"
                                            )
                                            .font(.caption)
                                        }
                                    }
                                    
                                }
                            }
                            .listStyle(.plain)
                            .refreshable {
                                await viewModel.sync()
                            }
                        }
                        Spacer()
                    }
                    VStack {
                        HStack(spacing: 5) {
                            Text(viewModel.walletSyncState.description)
                            if viewModel.walletSyncState == .syncing {
                                ProgressView()
                            }
                            
                        }
                        if let lastSyncTime = viewModel.lastSyncTime {
                            Text("Last Synced: \(lastSyncTime.formattedSyncTime())")
                                .font(.caption)
                        }
                    }
                    Button {
                        Task {
                            await viewModel.sync()
                        }
                    } label: {
                        Text("Sync")
                    }
                    .buttonStyle(BitcoinOutlined(tintColor: .bitcoinOrange))
                    .disabled(viewModel.walletSyncState == .syncing)
                }
                .padding()
                .onAppear {
                    viewModel.getBalance()
                    viewModel.getTransactions()
                }
                .task {
                    await viewModel.sync()
                    await viewModel.getPrice()
                }
                
            }
            
        }
        
    }
    
}

struct WalletView_Previews: PreviewProvider {
    static var previews: some View {
        WalletView(viewModel: .init(priceService: .init()))
            .previewDisplayName("Light Mode")
        WalletView(viewModel: .init(priceService: .init()))
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Dark Mode")
    }
}
