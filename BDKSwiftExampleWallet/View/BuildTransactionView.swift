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
    //    let feeClient: FeeClient
    let bdkClient: BDKClient

    var txBuilderResult: TxBuilderResult?
    //    var balanceTotal: UInt64?
    //    var recommendedFees: RecommendedFees?
    //    var selectedFeeIndex: Int = 2
    //    var selectedFee: Int? {
    //        guard let fees = recommendedFees else {
    //            return nil
    //        }
    //        switch selectedFeeIndex {
    //        case 0: return fees.minimumFee
    //        case 1: return fees.hourFee
    //        case 2: return fees.halfHourFee
    //        default: return fees.fastestFee
    //        }
    //    }
    //    var selectedFeeDescription: String {
    //        guard let selectedFee = selectedFee else {
    //            return "Failed to load fees"
    //        }
    //
    //        let feeText = text(for: selectedFeeIndex)
    //        return "Selected \(feeText) Fee: \(selectedFee) sats"
    //    }
    //    func text(for index: Int) -> String {
    //
    //        switch index {
    //
    //        //"Minimum Fee"
    //        case 0:
    //            return "No Priority"
    //
    //        //"Hour Fee"
    //        case 1:
    //            return "Low Priority"
    //
    //        //"Half Hour Fee"
    //        case 2:
    //            return "Medium Priority"
    //
    //        //"Fastest Fee"
    //        case 3:
    //            return "High Priority"
    //
    //        default:
    //            return ""
    //
    //        }
    //
    //    }

    init(
        //        feeClient: FeeClient = .live,
        bdkClient: BDKClient = .live
    ) {
        //        self.feeClient = feeClient
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

    //    func getFees() async {
    //        do {
    //            let recommendedFees = try await feeClient.fetchFees()
    //            self.recommendedFees = recommendedFees
    //        } catch {
    //            print("getFees error: \(error.localizedDescription)")
    //        }
    //    }

}

struct BuildTransactionView: View {
    let amount: String
    let address: String
    let fee: Int
    @Bindable var viewModel: BuildTransactionViewModel

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

                Button {
                    let feeRate: Float? = Float(fee)  //viewModel.selectedFee.map { Float($0) }
                    if let rate = feeRate {
                        if let amt = UInt64(amount) {
                            viewModel.send(
                                address: address,
                                amount: amt,
                                feeRate: rate
                            )
                            // TODO: dismiss after this success
                        } else {
                            print("no amount conversion")
                        }
                    } else {
                        print("no fee rate")
                    }
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
            print("Address: \(address)")
            print("Amount: \(amount)")
            let feeRate: Float? = Float(fee)  //viewModel.selectedFee.map { Float($0) }
            if let rate = feeRate {
                print("Fee Rate: \(String(describing: rate))")
                viewModel.buildTransaction(
                    address: address,
                    amount: UInt64(amount) ?? 0,
                    feeRate: rate  //Float(feeRate ?? 1)
                )
            } else {
                print("error no fee rate")
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
        )
    )
}