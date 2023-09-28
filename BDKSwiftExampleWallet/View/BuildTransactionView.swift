//
//  BuildTransactionView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 9/15/23.
//

import BitcoinDevKit
import BitcoinUI
import SwiftUI

struct BuildTransactionView: View {
    let amount: String
    let address: String
    let fee: Int
    @Bindable var viewModel: BuildTransactionViewModel
    @State var isSent: Bool = false
    @State var isError: Bool = false
    @Binding var shouldPopToRootView: Bool

    var body: some View {

        ZStack {
            Color(uiColor: .systemBackground)

            VStack {

                Spacer()

                VStack {
                    HStack {
                        Text("To")
                        Spacer()
                        Text(address)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .frame(maxWidth: 100)
                    }
                    HStack {
                        Text("Send")
                        Spacer()
                        if let sent = viewModel.txBuilderResult?.transactionDetails.sent,
                            let received = viewModel.txBuilderResult?.transactionDetails
                                .received,
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
                        if let fee = viewModel.txBuilderResult?.transactionDetails.fee {
                            Text(fee.delimiter)
                        } else {
                            Text("...")
                        }
                    }
                    HStack {
                        Text("Total")
                        Spacer()
                        if let sent = viewModel.txBuilderResult?.transactionDetails.sent,
                            let received = viewModel.txBuilderResult?.transactionDetails
                                .received,
                            let fee = viewModel.txBuilderResult?.transactionDetails.fee
                        {
                            let send = sent - received - fee  // TODO: this is probably overkill and should probably just be the same thing as whatever is in the $amount
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

                Spacer()

                if !isSent {
                    Button {
                        let feeRate: Float? = Float(fee)
                        if let rate = feeRate {
                            if let amt = UInt64(amount) {
                                viewModel.send(
                                    address: address,
                                    amount: amt,
                                    feeRate: rate
                                )
                                self.isSent = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    self.shouldPopToRootView = false
                                }
                            } else {
                                print("no amount conversion")
                                self.isError = true
                            }
                        } else {
                            print("no fee rate")
                            self.isError = true
                        }
                    } label: {
                        isError
                            ? Text("Error")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding(.all, 8)
                            : Text("Send")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding(.all, 8)
                    }
                    .buttonStyle(
                        isSent
                            ? BitcoinFilled(tintColor: .bitcoinRed, isCapsule: true)
                            : BitcoinFilled(tintColor: .bitcoinOrange, isCapsule: true)

                    )
                    .padding()

                } else {
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                }

            }

        }
        .padding()
        .navigationTitle("Transaction")
        .onAppear {
            let feeRate: Float? = Float(fee)
            if let rate = feeRate {
                viewModel.buildTransaction(
                    address: address,
                    amount: UInt64(amount) ?? 0,
                    feeRate: rate
                )
            }
        }

    }

}

#Preview{
    BuildTransactionView(
        amount: "100000",
        address: "tb1pxg0lakl0x4jee73f38m334qsma7mn2yv764x9an5ylht6tx8ccdsxtktrt",
        fee: 17,
        viewModel: .init(
            bdkClient: .mock
        ),
        shouldPopToRootView: .constant(false)
    )
}
