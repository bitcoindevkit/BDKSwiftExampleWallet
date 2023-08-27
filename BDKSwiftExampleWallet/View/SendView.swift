//
//  SendView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 6/20/23.
//

import SwiftUI
import WalletUI

struct SendView: View {
    @Bindable var viewModel: SendViewModel
    @State private var amount: String = ""
    @State private var address: String = ""
    
    var body: some View {
        
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 50){
                HStack(spacing: 15) {
                    Image(systemName: "bitcoinsign")
                        .foregroundColor(.secondary)
                        .font(.title)
                    if let balanceTotal = viewModel.balanceTotal {
                        Text(balanceTotal.formattedSatoshis())
                    } else {
                        let balanceTotal: UInt64 = 0
                        Text(balanceTotal.formattedSatoshis())
                            .foregroundColor(.secondary)
                    }
//                    Text(viewModel.balanceTotal.formattedSatoshis())
                    Text("sats")
                        .foregroundColor(.secondary)
                }
                .font(.largeTitle)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
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
                    VStack {
                        Picker("Select Fee", selection: $viewModel.selectedFeeIndex) {
                            Image(systemName: "gauge.with.dots.needle.0percent")
                                .tag(0)
                            Image(systemName: "gauge.with.dots.needle.33percent")
                                .tag(1)
                            Image(systemName: "gauge.with.dots.needle.50percent")
                                .tag(2)
                            Image(systemName: "gauge.with.dots.needle.67percent")
                                .tag(3)
                        }
                        .pickerStyle(.menu) // TODO: use `.menu`
                        .tint(.bitcoinOrange)
                        
                        Text(viewModel.selectedFeeDescription)
                    }
                }
                .padding(.vertical, 50.0)
                Button {
                    let feeRate: Float? = viewModel.selectedFee.map { Float($0) }
                    viewModel.send(
                        address: address,
                        amount: UInt64(amount) ?? UInt64(0),
                        feeRate: feeRate
                    )
                    // TODO: only if success clear out these fields?
                    amount = ""
                    address = ""
                } label: {
                    Text("Send")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding(.all, 8)
                }
                .buttonStyle(BitcoinFilled(tintColor: .bitcoinOrange, isCapsule: true))
            }
            .padding()
            .task {
                await viewModel.getFees()
            }
            
        }
        
    }
}

#Preview("SendView - en") {
    SendView(viewModel: .init(feeClient: .mock, bdkClient: .mock))
}

#Preview("SendView - fr") {
    SendView(viewModel: .init(feeClient: .mock, bdkClient: .mock))
        .environment(\.locale, .init(identifier: "fr"))
}
