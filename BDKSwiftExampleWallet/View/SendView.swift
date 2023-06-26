//
//  SendView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 6/20/23.
//

import SwiftUI
import WalletUI
import BitcoinDevKit

class SendViewModel: ObservableObject {
    
    @Published var balanceTotal: UInt64 = 0

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
}
struct SendView: View {
    @ObservedObject var viewModel: SendViewModel

    var body: some View {
        
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Your Balance")
                    .bold()
                    .foregroundColor(.secondary)
                HStack {
                    Text(viewModel.balanceTotal.delimiter)
                    Text("sats")
                }
                .font(.largeTitle)
                Spacer()
            }
            .padding()
            .onAppear {
                viewModel.getBalance()
            }
        }
        
    }
    
}

struct SendView_Previews: PreviewProvider {
    static var previews: some View {
        SendView(viewModel: .init())
            .previewDisplayName("Light Mode")
        SendView(viewModel: .init())
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Dark Mode")
    }
}
