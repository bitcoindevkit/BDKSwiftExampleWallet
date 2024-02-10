//
//  AddressView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 9/15/23.
//

import BitcoinUI
import SwiftUI

struct AddressView: View {
    let amount: String
    @State private var address: String = ""
    @Binding var rootIsActive: Bool

    var body: some View {

        ZStack {
            Color(uiColor: .systemBackground)

            VStack {

                Spacer()

                VStack {
                    HStack {
                        Text("Address")
                            .bold()
                        Spacer()
                    }
                    .padding(.horizontal, 15.0)
                    TextField(
                        "Enter address to send BTC to",
                        text: $address
                    )
                    .truncationMode(.middle)
                    .submitLabel(.done)
                    .lineLimit(1)
                    .padding()
                }

                Spacer()

                NavigationLink(
                    destination:
                        FeeView(
                            amount: amount,
                            address: address,
                            viewModel: .init(),
                            rootIsActive: self.$rootIsActive
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
            .navigationTitle("Address")

        }

    }

}

#Preview {
    AddressView(amount: "200", rootIsActive: .constant(false))
}

#Preview {
    AddressView(amount: "200", rootIsActive: .constant(false))
        .environment(\.sizeCategory, .accessibilityLarge)
}
