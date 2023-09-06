//
//  SendView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 6/20/23.
//

import BitcoinUI
import SwiftUI

struct SendView: View {
    @Bindable var viewModel: SendViewModel
    @State private var amount: String = ""
    @State private var address: String = ""

    var body: some View {

        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack {
                VStack(spacing: 8) {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .resizable()
                        .foregroundColor(.bitcoinOrange)
                        .fontWeight(.bold)
                        .frame(width: 50, height: 50, alignment: .center)
                    if let balance = viewModel.balanceTotal {
                        HStack(spacing: 2) {
                            Text(balance.delimiter)
                            Text("sats available")
                        }
                        .fontWeight(.semibold)
                    }
                }
                .font(.caption)
                .padding(.top, 40.0)

                Spacer()

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
                        .truncationMode(.middle) // TODO: this isn't truncating properly
                        .lineLimit(1)
                    }

                    VStack {

                        HStack {
                            Picker("Select Fee", selection: $viewModel.selectedFeeIndex) {
                                HStack {
                                    Image(systemName: "gauge.with.dots.needle.0percent")
                                    Text(
                                        "No Priority - \(viewModel.recommendedFees?.minimumFee ?? 1) sat/vB"
                                    )
                                }
                                .tag(0)
                                HStack {
                                    Image(systemName: "gauge.with.dots.needle.33percent")
                                    Text(
                                        "Low Priority - \(viewModel.recommendedFees?.hourFee ?? 1) sat/vB"
                                    )
                                }
                                .tag(1)
                                HStack {
                                    Image(systemName: "gauge.with.dots.needle.50percent")
                                    Text(
                                        "Med Priority - \(viewModel.recommendedFees?.halfHourFee ?? 1) sat/vB"
                                    )
                                }
                                .tag(2)
                                HStack {
                                    Image(systemName: "gauge.with.dots.needle.67percent")
                                    Text(
                                        "High Priority - \(viewModel.recommendedFees?.fastestFee ?? 1) sat/vB"
                                    )
                                }
                                .tag(3)
                            }
                            .pickerStyle(.menu)
                            .tint(.bitcoinOrange)
                            Spacer()
                        }

                        HStack {
                            Button {
                                if let amt = UInt64(amount),
                                    let feeRate = viewModel.selectedFee {
                                    viewModel.buildTransaction(
                                        address: address,
                                        amount: amt,
                                        feeRate: Float(feeRate)
                                    )
                                } else {
                                    print("something went wrong building transaction")
                                }
                            } label: {
                                Text("Build Transaction")
                            }
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.capsule)
                            .tint(.bitcoinOrange)
                            Spacer()
                        }
                        .padding()
                        
                        VStack {
                            HStack {
                                Text("Send")
                                Spacer()
                                if let sent = viewModel.txBuilderResult?.transactionDetails.sent,
                               let received = viewModel.txBuilderResult?.transactionDetails.received,
                                let fee = viewModel.txBuilderResult?.transactionDetails.fee
                                {
                                    let send = sent - received - fee
                                    Text(send.delimiter)
                                } else {
                                    Text("...")
                                }
                            }
                            HStack {
                                Text("Fee")
                                Spacer()
                                if let fee = viewModel.txBuilderResult?.transactionDetails.fee
                                {
                                    Text(fee.delimiter)
                                } else {
                                    Text("...")
                                }
                            }
                            HStack {
                                Text("Total")
                                Spacer()
                                if
                                    let sent = viewModel.txBuilderResult?.transactionDetails.sent,
                                   let received = viewModel.txBuilderResult?.transactionDetails.received,
                                    let fee = viewModel.txBuilderResult?.transactionDetails.fee
                                {
                                    let send = sent - received - fee // TODO: this is probably overkill and should probably just be the same thing as whatever is in the $amount
                                    let total = send + fee
                                    Text(total.delimiter)
                                } else {
                                    Text("...")
                                }
                            }
                        }
                        .font(.caption)
                        .fontWeight(.light)
                        .foregroundColor(.secondary)
                        .padding()
                        
                    }
                    
                }
                .padding()

                Button {
                    let feeRate: Float? = viewModel.selectedFee.map { Float($0) }
                    viewModel.send(
                        address: address,
                        amount: UInt64(amount) ?? UInt64(0),
                        feeRate: feeRate
                    )
                    // TODO: only if success clear out these fields?
                    // amount = ""
                    // address = ""
                } label: {
                    Text("Send")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding(.all, 8)
                }
                .buttonStyle(BitcoinFilled(tintColor: .bitcoinOrange, isCapsule: true))
                .padding()
            }
            .padding()
            .task {
                viewModel.getBalance()
                await viewModel.getFees()
            }

        }

    }
}

#Preview("SendView - en"){
    SendView(viewModel: .init(feeClient: .mock, bdkClient: .mock))
}

#Preview("SendView - fr"){
    SendView(viewModel: .init(feeClient: .mock, bdkClient: .mock))
        .environment(\.locale, .init(identifier: "fr"))
}
