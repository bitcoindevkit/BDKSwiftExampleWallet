//
//  WalletView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 5/23/23.
//

import SwiftUI

class WalletViewModel: ObservableObject {
    @Published var address: String = ""
    
    func getAddress() {
        do {
            let address = try BDKService.shared.getAddress()
            self.address = address
        } catch {
            print("WalletViewModel getAddress failed")
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
                Text("Address:")
                Text(viewModel.address)
                    .font(.caption)
            }
            .padding()
            .onAppear {
                viewModel.getAddress()
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
