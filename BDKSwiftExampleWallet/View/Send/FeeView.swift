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
    @Bindable var viewModel: FeeViewModel
    @Binding var navigationPath: NavigationPath
    let address: String
    let amount: String

    var body: some View {

        ZStack {
            Color(uiColor: .systemBackground)

            VStack {

                Spacer()

                HStack {
                    Spacer()

                    Picker("Select Fee", selection: $viewModel.selectedFeeIndex) {
                        HStack {
                            Image(
                                systemName: "bitcoinsign.gauge.chart.leftthird.topthird.rightthird",
                                variableValue: 0.0
                            )
                            Text(
                                " No Priority - \(viewModel.recommendedFees?.minimumFee ?? 1)"
                            )
                        }
                        .tag(0)
                        HStack {
                            Image(
                                systemName: "bitcoinsign.gauge.chart.leftthird.topthird.rightthird",
                                variableValue: 0.33
                            )
                            Text(
                                " Low Priority - \(viewModel.recommendedFees?.hourFee ?? 1)"
                            )
                        }
                        .tag(1)
                        HStack {
                            Image(
                                systemName: "bitcoinsign.gauge.chart.leftthird.topthird.rightthird",
                                variableValue: 0.66
                            )
                            Text(
                                " Med Priority - \(viewModel.recommendedFees?.halfHourFee ?? 1)"
                            )
                        }
                        .tag(2)
                        HStack {
                            Image(
                                systemName: "bitcoinsign.gauge.chart.leftthird.topthird.rightthird",
                                variableValue: 1.0
                            )
                            Text(
                                " High Priority - \(viewModel.recommendedFees?.fastestFee ?? 1)"
                            )
                        }
                        .tag(3)
                    }
                    .pickerStyle(.automatic)
                    .tint(.primary)
                    .accessibilityLabel("Select Transaction Fee")
                    .accessibilityValue("\(viewModel.selectedFee ?? 1) satoshis per vbyte")

                    Text("sat/vb")
                        .foregroundColor(.secondary)
                        .fontWeight(.thin)

                    Spacer()
                }

                Spacer()

                Button {
                    navigationPath.append(
                        NavigationDestination.buildTransaction(
                            amount: amount,
                            address: address,
                            fee: viewModel.selectedFee ?? 1
                        )
                    )
                } label: {
                    Label(
                        title: { Text("Next") },
                        icon: { Image(systemName: "arrow.right") }
                    )
                    .labelStyle(.iconOnly)
                }
                .buttonStyle(BitcoinOutlined(width: 100, isCapsule: true))

            }
            .padding()
            .navigationTitle("Fees")
            .task {
                await viewModel.getFees()
            }

        }
        .alert(isPresented: $viewModel.showingFeeViewErrorAlert) {
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
            viewModel: .init(feeClient: .mock, bdkClient: .mock),
            navigationPath: .constant(NavigationPath()),
            address: "tb1pxg0lakl0x4jee73f38m334qsma7mn2yv764x9an5ylht6tx8ccdsxtktrt",
            amount: "50"
        )
    }
#endif
