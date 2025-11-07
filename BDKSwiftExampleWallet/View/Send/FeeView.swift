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

                VStack(spacing: 12) {
                    Slider(
                        value: feeSliderBinding,
                        in: 0...3,
                        step: 1
                    ) {
                        Text("Fee Priority")
                    } minimumValueLabel: {
                        Text(feeTitle(for: 0))
                    } maximumValueLabel: {
                        Text(feeTitle(for: 3))
                    }
                    .tint(.primary)
                    .accessibilityLabel("Select Transaction Fee")
                    .accessibilityValue("\(viewModel.selectedFee ?? 1) satoshis per vbyte")

                    HStack(spacing: 8) {
                        ForEach(0..<4, id: \.self) { index in
                            VStack(spacing: 4) {
                                feeIcon(for: index)
                                    .font(.headline)
                                Text("\(feeTitle(for: index)) • \(feeValue(for: index))")
                                    .font(.caption2)
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(
                                        index == viewModel.selectedFeeIndex
                                            ? .primary : .secondary
                                    )
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }

                    Text("Selected: \(viewModel.selectedFee ?? 1) sat/vb fee")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

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
                .buttonStyle(
                    BitcoinOutlined(
                        width: 100,
                        tintColor: .primary,
                        isCapsule: true
                    )
                )

            }
            .padding()
            .navigationTitle("Fee Priority")
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

extension FeeView {
    fileprivate var feeSliderBinding: Binding<Double> {
        Binding(
            get: { Double(viewModel.selectedFeeIndex) },
            set: { viewModel.selectedFeeIndex = Int($0.rounded()) }
        )
    }

    fileprivate func feeValue(for index: Int) -> Int {
        guard let fees = viewModel.recommendedFees else { return 1 }
        switch index {
        case 0: return fees.minimumFee
        case 1: return fees.hourFee
        case 2: return fees.halfHourFee
        default: return fees.fastestFee
        }
    }

    fileprivate func feeTitle(for index: Int) -> String {
        switch index {
        case 0: return "None"
        case 1: return "Low"
        case 2: return "Medium"
        default: return "High"
        }
    }

    @ViewBuilder
    fileprivate func feeIcon(for index: Int) -> some View {
        Image(
            systemName: "bitcoinsign.gauge.chart.leftthird.topthird.rightthird",
            variableValue: Double(index) / 3.0
        )
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
