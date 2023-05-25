//
//  WalletView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 5/23/23.
//

import SwiftUI
import WalletUI

class WalletViewModel: ObservableObject {
    @Published var address: String = ""
    @Published var walletSyncState: WalletSyncState = .notStarted
    
    enum WalletSyncState: CustomStringConvertible {
        case error
        case notStarted
        case synced
        case syncing
        
        var description: String {
            switch self {
            case .error:
                return "Error Syncing"
            case .notStarted:
                return "Not Started"
            case .synced:
                return "Synced"
            case .syncing:
                return "Syncing"
            }
        }
    }
    
    func getAddress() {
        do {
            let address = try BDKService.shared.getAddress()
            self.address = address
        } catch {
            self.address = "Error getting address."
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
                }
            } catch {
                DispatchQueue.main.async {
                    self.walletSyncState = .error
                }
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
            
            VStack {
                VStack {
                    Text("Address:")
                    Text(viewModel.address)
                        .font(.caption)
                }
                HStack(spacing: 5) {
                    Text(viewModel.walletSyncState.description)
                    if viewModel.walletSyncState == .syncing {
                        ProgressView()
                    }
                }
            }
            .padding()
            .onAppear {
                viewModel.getAddress()
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
