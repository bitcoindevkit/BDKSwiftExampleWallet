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
                        Text("\(numpadAmount.formattedWithSeparator) sats")
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

                    GeometryReader { geometry in
                        let buttonSize = geometry.size.width / 4

                        VStack(spacing: buttonSize / 10) {
                            numpadRow(["1", "2", "3"], buttonSize: buttonSize)
                            numpadRow(["4", "5", "6"], buttonSize: buttonSize)
                            numpadRow(["7", "8", "9"], buttonSize: buttonSize)
                            numpadRow([" ", "0", "<"], buttonSize: buttonSize)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .frame(height: 300)  // Adjust this height as needed

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

    func numpadRow(_ characters: [String], buttonSize: CGFloat) -> some View {
        HStack(spacing: buttonSize / 2) {
            ForEach(characters, id: \.self) { character in
                NumpadButton(numpadAmount: $numpadAmount, character: character)
                    .frame(width: buttonSize, height: buttonSize)
            }
        }
    }
}

//struct AmountView: View {
//    @Bindable var viewModel: AmountViewModel
//    @State var numpadAmount = "0"
//
//    var body: some View {
//        NavigationView {
//            ZStack {
//                Color(uiColor: .systemBackground)
//
//                VStack(spacing: 50) {
//                    Spacer()
//
//                    VStack(spacing: 4) {
//                        Text("\(numpadAmount) sats")
//                            .textStyle(BitcoinTitle1())
//                        if let balance = viewModel.balanceTotal {
//                            HStack(spacing: 2) {
//                                Text(balance.delimiter)
//                                Text("sats available")
//                            }
//                            .fontWeight(.semibold)
//                            .font(.caption)
//                        }
//                    }
//
//                    VStack(spacing: 100) {
//                        createNumpadRow(["1", "2", "3"])
//                        createNumpadRow(["4", "5", "6"])
//                        createNumpadRow(["7", "8", "9"])
//                        createNumpadRow([" ", "0", "<"])
//                    }
//                    .frame(maxWidth: .infinity)
//
//                    Spacer()
//
//                    NavigationLink(
//                        destination: AddressView(amount: numpadAmount)
//                    ) {
//                        Label(
//                            title: { Text("Next") },
//                            icon: { Image(systemName: "arrow.right") }
//                        )
//                        .labelStyle(.iconOnly)
//                    }
//                    .buttonStyle(BitcoinFilled(width: 100, isCapsule: true))
//                }
//                .padding()
//                .task {
//                    viewModel.getBalance()
//                }
//            }
//        }
//    }
//
//    func createNumpadRow(_ characters: [String]) -> some View {
//        HStack {
//            Spacer()
//            ForEach(characters, id: \.self) { char in
//                NumpadButton(numpadAmount: $numpadAmount, character: char)
//                Spacer()
//            }
//        }
//    }
//}

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
