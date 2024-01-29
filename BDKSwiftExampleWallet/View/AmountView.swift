//
//  AmountView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 9/15/23.
//

import BitcoinUI
import SwiftUI

struct AmountView: View {
    @Bindable var viewModel: AmountViewModel
    @State var numpadAmount = "0"
    @State var isActive: Bool = false
    @State private var showingAmountViewErrorAlert = false

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
                                Text("total")
                            }
                            .fontWeight(.semibold)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        if let balance = viewModel.balanceConfirmed {
                            HStack(spacing: 2) {
                                Text(balance.delimiter)
                                Text("confirmed")
                            }
                            .fontWeight(.semibold)
                            .font(.caption)
                            .foregroundColor(.secondary)
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
                    .frame(height: 300)

                    Spacer()

                    NavigationLink(
                        destination: AddressView(amount: numpadAmount, rootIsActive: $isActive)
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
                .task {
                    viewModel.getBalance()
                }
            }
            .onChange(of: isActive) {
                if !isActive {
                    numpadAmount = "0"
                }
            }
        }
        .alert(isPresented: $showingAmountViewErrorAlert) {
            Alert(
                title: Text("Amount Error"),
                message: Text(viewModel.amountViewError?.description ?? "Unknown"),
                dismissButton: .default(Text("OK")) {
                    viewModel.amountViewError = nil
                }
            )
        }

    }

}

extension AmountView {
    func numpadRow(_ characters: [String], buttonSize: CGFloat) -> some View {
        HStack(spacing: buttonSize / 2) {
            ForEach(characters, id: \.self) { character in
                NumpadButton(numpadAmount: $numpadAmount, character: character)
                    .frame(width: buttonSize, height: buttonSize)
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

#Preview {
    AmountView(viewModel: .init(bdkClient: .mock))
}
