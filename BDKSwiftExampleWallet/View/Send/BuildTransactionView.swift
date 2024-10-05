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
    @Bindable var viewModel: BuildTransactionViewModel
    @Binding var navigationPath: NavigationPath
    @Environment(\.colorScheme) var colorScheme
    @State private var isCopied = false
    @State var isError: Bool = false
    @State var isSent: Bool = false
    @State private var showCheckmark = false
    let address: String
    let amount: String
    let fee: Int

    var body: some View {

        ZStack {
            Color(uiColor: .systemBackground)

            VStack {

                Spacer()

                VStack(spacing: 20) {

                    Spacer()

                    VStack(spacing: 40) {

                        if let sentAmount = UInt64(amount),
                            let feeAmountString = viewModel.calculateFee,
                            let feeAmount = UInt64(feeAmountString)
                        {
                            let total = sentAmount + feeAmount
                            let totalFormatted = String(total).formattedWithSeparator
                            Text("\(totalFormatted) sats")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .fontDesign(.rounded)
                                .foregroundStyle(.primary)
                        } else {
                            Text("...")
                        }

                        VStack(spacing: 0) {
                            HStack {
                                Text("Send")
                                Spacer()
                                Text(amount.formattedWithSeparator)
                            }
                            .padding(.bottom, 8)

                            Divider()
                                .background(Color(uiColor: .systemGray6))

                            HStack {
                                Text("Fee")
                                Spacer()
                                if let fee = viewModel.calculateFee {
                                    Text(fee.formattedWithSeparator)
                                } else {
                                    Text("...")
                                }
                            }
                            .padding(.vertical, 8)

                            Divider()
                                .background(Color(uiColor: .systemGray6))

                            HStack {
                                Text("Total")
                                Spacer()
                                if let sentAmount = UInt64(amount),
                                    let feeAmountString = viewModel.calculateFee,
                                    let feeAmount = UInt64(feeAmountString)
                                {
                                    let total = sentAmount + feeAmount
                                    Text(String(total).formattedWithSeparator)
                                } else {
                                    Text("...")
                                }
                            }
                            .padding(.top, 8)
                            .fontWeight(.semibold)
                        }
                        .padding()
                        .background(
                            Color(uiColor: .secondarySystemBackground)
                                .opacity(colorScheme == .dark ? 0.5 : 0.2)
                        )
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(uiColor: .systemGray6), lineWidth: 1)
                        )

                        AddressFormattedView(
                            address: address,
                            columns: 4,
                            spacing: 20.0,
                            gridItemSize: 60.0
                        )

                    }
                    .padding()

                    Spacer()

                    if !isSent {
                        Button {
                            if let amt = UInt64(amount) {
                                viewModel.buildTransactionViewError = nil
                                isError = false
                                viewModel.send(
                                    address: address,
                                    amount: amt,
                                    feeRate: UInt64(fee)
                                )
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    if self.viewModel.buildTransactionViewError == nil {
                                        self.isSent = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                            self.navigationPath.removeLast(
                                                self.navigationPath.count
                                            )
                                        }
                                    } else {
                                        self.isSent = false
                                        self.isError = true
                                    }
                                }
                            } else {
                            }
                        } label: {
                            Text("Send")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding(.all, 8)
                        }
                        .buttonStyle(
                            isSent
                                ? BitcoinFilled(
                                    tintColor: .secondary,
                                    textColor: Color(uiColor: .systemBackground),
                                    isCapsule: true
                                )
                                : BitcoinFilled(
                                    tintColor: .primary,
                                    textColor: Color(uiColor: .systemBackground),
                                    isCapsule: true
                                )
                        )
                        .padding()
                        .accessibilityLabel("Send Transaction")
                        .disabled(isError)

                    } else if isSent && !isError {
                        VStack {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.green)
                            if let transaction = viewModel.extractTransaction() {
                                HStack {
                                    Text(transaction.computeTxid())
                                        .lineLimit(1)
                                        .truncationMode(.middle)
                                    Spacer()
                                    Button {
                                        UIPasteboard.general.string = transaction.computeTxid()
                                        isCopied = true
                                        showCheckmark = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            isCopied = false
                                            showCheckmark = false
                                        }
                                    } label: {
                                        HStack {
                                            withAnimation {
                                                Image(
                                                    systemName: showCheckmark
                                                        ? "checkmark" : "doc.on.doc"
                                                )
                                                .foregroundStyle(.primary)
                                            }
                                        }
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.primary)
                                    }
                                }
                                .fontDesign(.monospaced)
                                .font(.caption)
                                .padding()
                            }

                        }
                    }
                }

            }
            .padding()
            .navigationTitle("Transaction")
            .onAppear {
                viewModel.buildTransaction(
                    address: address,
                    amount: UInt64(amount) ?? 0,
                    feeRate: UInt64(fee)
                )
                if let tx = viewModel.extractTransaction() {
                    viewModel.getCalulateFee(tx: tx)
                }
            }
            .alert(isPresented: $viewModel.showingBuildTransactionViewErrorAlert) {
                Alert(
                    title: Text("Build Transaction Error"),
                    message: Text(viewModel.buildTransactionViewError?.description ?? "Unknown"),
                    dismissButton: .default(Text("OK")) {
                        viewModel.buildTransactionViewError = nil
                        isError = true
                        isSent = false
                    }
                )
            }

        }

    }

}

#if DEBUG
    #Preview {
        BuildTransactionView(
            viewModel: .init(
                bdkClient: .mock
            ),
            navigationPath: .constant(.init()),
            address: "tb1pxg0lakl0x4jee73f38m334qsma7mn2yv764x9an5ylht6tx8ccdsxtktrt",
            amount: "100000",
            fee: 17
        )
    }
#endif
