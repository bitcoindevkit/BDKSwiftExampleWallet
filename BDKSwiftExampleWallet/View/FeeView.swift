//
//  FeeView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 9/15/23.
//

import BitcoinDevKit
import BitcoinUI
import Observation
import SwiftUI

@MainActor
@Observable
class FeeViewModel {
    let feeClient: FeeClient
    let bdkClient: BDKClient

    var txBuilderResult: TxBuilderResult?
    var recommendedFees: RecommendedFees?
    var selectedFeeIndex: Int = 2
    var selectedFee: Int? {
        guard let fees = recommendedFees else {
            return nil
        }
        switch selectedFeeIndex {
        case 0: return fees.minimumFee
        case 1: return fees.hourFee
        case 2: return fees.halfHourFee
        default: return fees.fastestFee
        }
    }
    var selectedFeeDescription: String {
        guard let selectedFee = selectedFee else {
            return "Failed to load fees"
        }

        let feeText = text(for: selectedFeeIndex)
        return "Selected \(feeText) Fee: \(selectedFee) sats"
    }
    func text(for index: Int) -> String {

        switch index {

        //"Minimum Fee"
        case 0:
            return "No Priority"

        //"Hour Fee"
        case 1:
            return "Low Priority"

        //"Half Hour Fee"
        case 2:
            return "Medium Priority"

        //"Fastest Fee"
        case 3:
            return "High Priority"

        default:
            return ""

        }

    }

    init(feeClient: FeeClient = .live, bdkClient: BDKClient = .live) {
        self.feeClient = feeClient
        self.bdkClient = bdkClient
    }

    func getFees() async {
        do {
            let recommendedFees = try await feeClient.fetchFees()
            self.recommendedFees = recommendedFees
        } catch {
            print("getFees error: \(error.localizedDescription)")
        }
    }

}

struct FeeView: View {
    let amount: String
    let address: String
    @Bindable var viewModel: FeeViewModel

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
                        viewModel: .init()
                    )
                ) {
                    Label(
                        title: { Text("Next") },
                        icon: { Image(systemName: "arrow.right") }
                    )
                    .labelStyle(.iconOnly)
                }
                .buttonStyle(BitcoinFilled(width: 100, isCapsule: true))

            }
            .navigationTitle("Fees")
            .task {
                await viewModel.getFees()
            }

        }

    }

}

#Preview{
    FeeView(
        amount: "50",
        address: "tb1pxg0lakl0x4jee73f38m334qsma7mn2yv764x9an5ylht6tx8ccdsxtktrt",
        viewModel: .init(feeClient: .mock, bdkClient: .mock)
    )
}
