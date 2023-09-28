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

    var body: some View {

        NavigationStack {

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
                        .lineLimit(1)
                        .padding()
                    }

                    Spacer()

                    NavigationLink(
                        destination:
                            FeeView(amount: amount, address: address, viewModel: .init())
                    ) {
                        Label(
                            title: { Text("Next") },
                            icon: { Image(systemName: "arrow.right") }
                        )
                        .labelStyle(.iconOnly)
                    }
                    .buttonStyle(BitcoinOutlined(width: 100, isCapsule: true))

                }
                .padding()
                .navigationTitle("Address")

            }

        }

    }

}

#Preview{
    AddressView(amount: "200")
}
