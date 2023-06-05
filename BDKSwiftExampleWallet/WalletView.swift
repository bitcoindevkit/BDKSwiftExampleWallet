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
    // Address
    @Published var address: String = ""
    
    // Balance
    @Published var balanceImmature: UInt64 = 0
    @Published var balanceTrustedPending: UInt64 = 0
    @Published var balanceUntrustedPending: UInt64 = 0
    @Published var balanceConfirmed: UInt64 = 0
    @Published var balanceTotal: UInt64 = 0
    @Published var balanceSpendable: UInt64 = 0

    // Sync
    @Published var lastSyncTime: Date? = nil
    @Published var walletSyncState: WalletSyncState = .notStarted

    func getAddress() {
        do {
            let address = try BDKService.shared.getAddress()
            self.address = address
        } catch {
            self.address = "Error getting address."
        }
    }
    
    func getBalance() {
        do {
            let balance = try BDKService.shared.getBalance()
            self.balanceTotal = balance.total
            self.balanceSpendable = balance.spendable
            self.balanceImmature = balance.immature
            self.balanceTrustedPending = balance.trustedPending
            self.balanceUntrustedPending = balance.untrustedPending
            self.balanceConfirmed = balance.confirmed
        } catch let error as WalletError {
            print("getBalance - Wallet Error: \(error.localizedDescription)")
        } catch {
            print("getBalance - Undefined Error: \(error.localizedDescription)")
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
                    self.getAddress()
                    self.getBalance()
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
    enum WalletSyncState: CustomStringConvertible {
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
    
    var body: some View {
        
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                VStack {
                    Text("Address:")
                    Text(viewModel.address)
                        .font(.caption)
                }
                VStack {
                    VStack {
                        Text("Total Balance:")
                        Text(String(viewModel.balanceTotal))
                            .font(.largeTitle)
                    }
                    HStack {
                        Text("Immature Balance:")
                        Text(String(viewModel.balanceImmature))
                    }
                    .font(.caption)
                    HStack {
                        Text("Trusted Pending Balance:")
                        Text(String(viewModel.balanceTrustedPending))
                    }
                    .font(.caption)
                    HStack {
                        Text("Untrusted Pending Balance:")
                        Text(String(viewModel.balanceUntrustedPending))
                    }
                    .font(.caption)
                    HStack {
                        Text("Confirmed Balance:")
                        Text(String(viewModel.balanceConfirmed))
                    }
                    .font(.caption)
                    HStack {
                        Text("Spendable Balance:")
                        Text(String(viewModel.balanceSpendable))
                    }
                    .font(.caption)
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
                viewModel.getAddress()
                viewModel.getBalance()
            }
            .task {
                await viewModel.sync()
            }
            
        }
        
    }
    
}

struct WalletView_Previews: PreviewProvider {
    static var previews: some View {
        WalletView(viewModel: .init())
            .previewDisplayName("Light Mode")
        WalletView(viewModel: .init())
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Dark Mode")
    }
}
