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

            VStack(spacing: 50) {
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

                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)

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

                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)

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

                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)

                    VStack {

                        HStack {
                            Text("Fee")
                                .bold()
                            Spacer()
                        }
                        .padding(.horizontal, 15.0)
                        HStack {

                            if let selectedFee = viewModel.selectedFee {
                                Text(String(selectedFee))
                                    .padding(.horizontal, 15.0)
                            }

                            Spacer()

                            Picker("Select Fee", selection: $viewModel.selectedFeeIndex) {
                                HStack {
                                    Image(systemName: "gauge.with.dots.needle.0percent")
                                    Text("No - \(viewModel.recommendedFees?.minimumFee ?? 0)")
                                }
                                .tag(0)

                                HStack {
                                    Image(systemName: "gauge.with.dots.needle.33percent")
                                    Text("Low - \(viewModel.recommendedFees?.hourFee ?? 0)")
                                }
                                .tag(1)

                                HStack {
                                    Image(systemName: "gauge.with.dots.needle.50percent")
                                    Text("Med - \(viewModel.recommendedFees?.halfHourFee ?? 0)")
                                }
                                .tag(2)

                                HStack {
                                    Image(systemName: "gauge.with.dots.needle.67percent")
                                    Text("High - \(viewModel.recommendedFees?.fastestFee ?? 0)")
                                }
                                .tag(3)
                            }
                            .pickerStyle(.menu)
                            .tint(.bitcoinOrange)

                        }
                    }
                }
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

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

#Preview("SendView - en"){
    SendView(viewModel: .init(feeClient: .mock, bdkClient: .mock))
}

#Preview("SendView - fr"){
    SendView(viewModel: .init(feeClient: .mock, bdkClient: .mock))
        .environment(\.locale, .init(identifier: "fr"))
}
