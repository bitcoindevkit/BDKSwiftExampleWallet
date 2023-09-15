//
//  AmountView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 9/15/23.
//

import BitcoinUI
import Observation
import SwiftUI

@MainActor
@Observable
class AmountViewModel {
    let bdkClient: BDKClient

    var balanceTotal: UInt64?

    init(bdkClient: BDKClient = .live) {
        self.bdkClient = bdkClient
    }

    func getBalance() {
        do {
            let balance = try bdkClient.getBalance()
            self.balanceTotal = balance.total
        } catch let error as WalletError {
            print("getBalance - Send Error: \(error.localizedDescription)")
        } catch {
            print("getBalance - Undefined Error: \(error.localizedDescription)")
        }
    }

}

struct AmountView: View {
    @Bindable var viewModel: AmountViewModel
    @State var numpadAmount = "0"

    var body: some View {

        NavigationView {

            ZStack {
                Color(uiColor: .systemBackground)

                VStack(spacing: 50) {

                    Spacer()

                    VStack(spacing: 4) {
                        Text("\(numpadAmount) sats")
                            .textStyle(BitcoinTitle1())
                        if let balance = viewModel.balanceTotal {
                            HStack(spacing: 2) {
                                Text(balance.delimiter)
                                Text("sats available")
                            }
                            .fontWeight(.semibold)
                            .font(.caption)
                        }
                    }
                    VStack(spacing: 50) {
                        HStack(spacing: 100) {
                            NumpadButton(numpadAmount: $numpadAmount, character: "1")
                            NumpadButton(numpadAmount: $numpadAmount, character: "2")
                            NumpadButton(numpadAmount: $numpadAmount, character: "3")
                        }
                        HStack(spacing: 100) {
                            NumpadButton(numpadAmount: $numpadAmount, character: "4")
                            NumpadButton(numpadAmount: $numpadAmount, character: "5")
                            NumpadButton(numpadAmount: $numpadAmount, character: "6")
                        }
                        HStack(spacing: 100) {
                            NumpadButton(numpadAmount: $numpadAmount, character: "7")
                            NumpadButton(numpadAmount: $numpadAmount, character: "8")
                            NumpadButton(numpadAmount: $numpadAmount, character: "9")
                        }
                        HStack(spacing: 100) {
                            NumpadButton(numpadAmount: $numpadAmount, character: " ")
                            NumpadButton(numpadAmount: $numpadAmount, character: "0")
                            NumpadButton(numpadAmount: $numpadAmount, character: "<")
                        }
                    }

                    Spacer()

                    NavigationLink(
                        destination: AddressView(amount: numpadAmount)
                    ) {
                        Label(
                            title: { Text("Next") },
                            icon: { Image(systemName: "arrow.right") }
                        )
                        .labelStyle(.iconOnly)
                    }
                    .buttonStyle(BitcoinFilled(width: 100, isCapsule: true))

                }
                .padding()
                .task {
                    viewModel.getBalance()
                }

            }
        }
    }
}

struct NumpadButton: View {
    @Binding var numpadAmount: String
    var character: String

    var body: some View {
        Button {
            if character == "<" {
                if numpadAmount.count > 1 {
                    numpadAmount.removeLast()
                } else {
                    numpadAmount = "0"
                }
            } else if character == " " {
                return
            } else {
                if numpadAmount == "0" {
                    numpadAmount = character
                } else {
                    numpadAmount.append(character)
                }
            }
        } label: {
            Text(character).textStyle(BitcoinTitle3())
        }
    }
}

#Preview{
    AmountView(viewModel: .init(bdkClient: .mock))
}
