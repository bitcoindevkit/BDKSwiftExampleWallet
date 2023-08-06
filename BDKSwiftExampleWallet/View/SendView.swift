//
//  SendView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 6/20/23.
//

import SwiftUI
import WalletUI

struct SendView: View {
    @ObservedObject var viewModel: SendViewModel
    @State private var amount: String = ""
    @State private var address: String = ""
    
    var body: some View {
        
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 50){
                
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
                VStack(spacing: 25) {
                    VStack {
                        HStack {
                            Text("Amount")
                                .bold()
                            Spacer()
                        }
                        .padding(.horizontal, 15.0)
                        TextField(
                            "Enter amount to send",
                            text: $amount
                        )
                        .padding()
                        .keyboardType(.numberPad)
                    }
                    VStack {
                        HStack {
                            Text("Address")
                                .bold()
                            Spacer()
                        }
                        .padding(.horizontal, 15.0)
                        TextField(
                            "Enter address to send BTC to",
                            text: $address
                        )
                        .padding()
                        .truncationMode(.middle)
                        .lineLimit(1)
                    }
                }
                .padding(.vertical, 50.0)
                Button {
                    viewModel.send(
                        address: address,
                        amount: UInt64(amount) ?? UInt64(0),
                        feeRate: nil
                    )
                    amount = ""
                    address = ""
                } label: {
                    Text("Send")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding(.all, 8)
                }
                .buttonStyle(BitcoinOutlined(tintColor: .bitcoinOrange))
            }
            .padding()
            
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
