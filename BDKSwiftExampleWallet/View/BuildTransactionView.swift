//
//  BuildTransactionView.swift
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
class BuildTransactionViewModel {
    let feeClient: FeeClient
    let bdkClient: BDKClient

    var txBuilderResult: TxBuilderResult?
    //    var balanceTotal: UInt64?
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

    func buildTransaction(address: String, amount: UInt64, feeRate: Float?) {
        do {
            let txBuilderResult = try bdkClient.buildTransaction(address, amount, feeRate)
            self.txBuilderResult = txBuilderResult
        } catch let error as WalletError {
            print("buildTransaction - Send Error: \(error.localizedDescription)")
        } catch let error as BdkError {
            print("buildTransaction - BDK Error: \(error.description)")
        } catch {
            print("buildTransaction - Undefined Error: \(error.localizedDescription)")
        }
    }

    func send(address: String, amount: UInt64, feeRate: Float?) {
        do {
            try bdkClient.send(address, amount, feeRate)
            NotificationCenter.default.post(
                name: Notification.Name("TransactionSent"),
                object: nil
            )
        } catch let error as WalletError {
            print("send - Send Error: \(error.localizedDescription)")
        } catch let error as BdkError {
            print("send - BDK Error: \(error.description)")
        } catch {
            print("send - Undefined Error: \(error.localizedDescription)")
        }
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

struct BuildTransactionView: View {
    let amount: String
    let address: String
    @Bindable var viewModel: BuildTransactionViewModel

    var body: some View {

        ZStack {
            Color(uiColor: .systemBackground)

            VStack {

                HStack {
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
                    .pickerStyle(.menu)
                    .tint(.bitcoinOrange)
                    Text("sat/vb")
                        .foregroundColor(.secondary)
                        .fontWeight(.thin)
                    Spacer()
                }

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

                Button {
                    let feeRate: Float? = viewModel.selectedFee.map { Float($0) }
                    viewModel.send(
                        address: address,
                        amount: UInt64(amount) ?? UInt64(0),
                        feeRate: feeRate
                    )
                } label: {
                    Text("Send")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding(.all, 8)
                }
                .buttonStyle(BitcoinFilled(tintColor: .bitcoinOrange, isCapsule: true))
                .padding()

            }

        }
        .padding()
        .task {
            await viewModel.getFees()
            print("Address: \(address)")
            print("Amount: \(amount)")
            let feeRate: Float? = viewModel.selectedFee.map { Float($0) }
            print("Fee Rate: \(String(describing: feeRate))")
            viewModel.buildTransaction(
                address: address,
                amount: UInt64(amount) ?? 0,
                feeRate: Float(feeRate ?? 1)
            )
        }

    }

}

#Preview{
    BuildTransactionView(
        amount: "100",
        address: "address",
        viewModel: .init(feeClient: .mock, bdkClient: .mock)
    )
}
