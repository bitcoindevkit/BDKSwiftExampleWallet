//
//  FeeView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 9/15/23.
//

import BitcoinDevKit
import BitcoinUI
import SwiftUI

struct FeeView: View {
    let amount: String
    let address: String
    @Bindable var viewModel: FeeViewModel
    @Binding var rootIsActive: Bool
    @State private var showingFeeViewErrorAlert = false

    var body: some View {

        ZStack {
            Color(uiColor: .systemBackground)

            VStack {

                Spacer()

                HStack {
                    Spacer()
                    Picker("Select Fee", selection: $viewModel.selectedFeeIndex) {
                        HStack {
                            Image(systemName: "gauge.with.dots.needle.0percent")
                            Text(
                                " No Priority - \(viewModel.recommendedFees?.minimumFee ?? 1)"
                            )
                        }
                        .tag(0)
                        HStack {
                            Image(systemName: "gauge.with.dots.needle.33percent")
                            Text(
                                " Low Priority - \(viewModel.recommendedFees?.hourFee ?? 1)"
                            )
                        }
                        .tag(1)
                        HStack {
                            Image(systemName: "gauge.with.dots.needle.50percent")
                            Text(
                                " Med Priority - \(viewModel.recommendedFees?.halfHourFee ?? 1)"
                            )
                        }
                        .tag(2)
                        HStack {
                            Image(systemName: "gauge.with.dots.needle.67percent")
                            Text(
                                " High Priority - \(viewModel.recommendedFees?.fastestFee ?? 1)"
                            )
                        }
                        .tag(3)
                    }
                    .pickerStyle(.automatic)
                    .tint(.bitcoinOrange)
                    Text("sat/vb")
                        .foregroundColor(.secondary)
                        .fontWeight(.thin)
                    Spacer()
                }

                Spacer()

                NavigationLink(
                    destination: BuildTransactionView(
                        amount: amount,
                        address: address,
                        fee: viewModel.selectedFee ?? 1,
                        viewModel: .init(),
                        shouldPopToRootView: self.$rootIsActive

                    )
                ) {
                    Label(
                        title: { Text("Next") },
                        icon: { Image(systemName: "arrow.right") }
                    )
                    .labelStyle(.iconOnly)
                }
                .isDetailLink(false)
                .buttonStyle(BitcoinOutlined(width: 100, isCapsule: true))

            }
            .padding()
            .navigationTitle("Fees")
            .task {
                await viewModel.getFees()
            }

        }
        .alert(isPresented: $showingFeeViewErrorAlert) {
            Alert(
                title: Text("Fee Error"),
                message: Text(viewModel.feeViewError?.description ?? "Unknown"),
                dismissButton: .default(Text("OK")) {
                    viewModel.feeViewError = nil
                }
            )
        }

    }

}

#if DEBUG
    #Preview {
        FeeView(
            amount: "50",
            address: "tb1pxg0lakl0x4jee73f38m334qsma7mn2yv764x9an5ylht6tx8ccdsxtktrt",
            viewModel: .init(feeClient: .mock, bdkClient: .mock),
            rootIsActive: .constant(false)
        )
    }

    #Preview {
        FeeView(
            amount: "50",
            address: "tb1pxg0lakl0x4jee73f38m334qsma7mn2yv764x9an5ylht6tx8ccdsxtktrt",
            viewModel: .init(feeClient: .mock, bdkClient: .mock),
            rootIsActive: .constant(false)
        )
        .environment(\.sizeCategory, .accessibilityLarge)
    }
#endif
