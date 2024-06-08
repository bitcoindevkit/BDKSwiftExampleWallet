//
//  AddressView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 9/15/23.
//

import BitcoinUI
import CodeScanner
import SwiftUI

struct AddressView: View {
    let amount: String
    @State private var address: String = ""
    @Binding var rootIsActive: Bool
    let pasteboard = UIPasteboard.general
    @State private var isShowingScanner = false
    @State private var isShowingAlert = false
    @State private var alertMessage = ""

    var body: some View {

        ZStack {
            Color(uiColor: .systemBackground)

            VStack {

                HStack {

                    Button {
                        isShowingScanner = true
                    } label: {
                        HStack {
                            Image(systemName: "qrcode.viewfinder")
                                .minimumScaleFactor(0.5)
                        }
                    }

                    Spacer()

                    Button {
                        if pasteboard.hasStrings {
                            if let string = pasteboard.string {
                                let lowercaseAddress = string.lowercased()
                                address = lowercaseAddress
                            } else {
                                alertMessage = "Unable to get the string from the pasteboard."
                                isShowingAlert = true
                            }
                        } else {
                            alertMessage = "No strings found in the pasteboard."
                            isShowingAlert = true
                        }
                    } label: {
                        HStack {
                            Image(systemName: "doc.on.doc")
                                .minimumScaleFactor(0.5)
                        }
                    }

                }
                .font(.largeTitle)
                .foregroundColor(Color(UIColor.label))
                .padding(.top)
                .sheet(isPresented: $isShowingScanner) {
                    CodeScannerView(
                        codeTypes: [.qr],
                        simulatedData: "1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2",
                        completion: handleScan
                    )
                }

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

extension AddressView {
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        switch result {
        case .success(let result):
            let scannedAddress = result.string.lowercased().replacingOccurrences(
                of: "bitcoin:",
                with: ""
            )
            let components = scannedAddress.components(separatedBy: "?")
            if let bitcoinAddress = components.first {
                address = bitcoinAddress
            } else {
                alertMessage = "The scanned QR code did not contain a valid Bitcoin address."
                isShowingAlert = true
            }
        case .failure(let error):
            alertMessage = "Scanning failed: \(error.localizedDescription)"
            isShowingAlert = true
        }
    }
}

#if DEBUG
    #Preview {
        AddressView(amount: "200", rootIsActive: .constant(false))
    }

    #Preview {
        AddressView(amount: "200", rootIsActive: .constant(false))
            .environment(\.sizeCategory, .accessibilityLarge)
    }
#endif
