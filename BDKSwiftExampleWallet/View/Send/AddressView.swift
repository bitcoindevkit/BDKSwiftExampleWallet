//
//  AddressView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 9/15/23.
//

import AVFoundation
import BitcoinUI
import CodeScanner
import SwiftUI

struct AddressView: View {
    let amount: String
    @State var address: String = ""
    @Binding var navigationPath: NavigationPath
    let pasteboard = UIPasteboard.general
    @State private var isShowingScanner = false
    @State private var isShowingAlert = false
    @State private var alertMessage = ""

    var body: some View {

        ZStack {
            Color(uiColor: .systemBackground)

            VStack {

                HStack {

                    Spacer()

                    Button {
                        isShowingScanner = true
                    } label: {
                        HStack {
                            Image(systemName: "qrcode.viewfinder")
                                .minimumScaleFactor(0.5)
                        }
                    }

                }
                .font(.largeTitle)
                .foregroundColor(Color(UIColor.label))
                .padding(.top)
                .sheet(isPresented: $isShowingScanner) {
                    CustomScannerView(
                        codeTypes: [.qr],
                        completion: handleScan,
                        pasteAction: pasteAddress
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

                AddressFormattedView(
                    address: address,
                    columns: 4,
                    spacing: 20.0,
                    gridItemSize: 60.0
                )
                .padding()

                Spacer()

                Button {
                    navigationPath.append(
                        NavigationDestination.fee(amount: amount, address: address)
                    )
                } label: {
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
            .alert(isPresented: $isShowingAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }

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

    private func pasteAddress() {
        if pasteboard.hasStrings {
            if let string = pasteboard.string {
                let lowercaseAddress = string.lowercased()
                address = lowercaseAddress
                isShowingScanner = false
            } else {
                alertMessage = "Unable to get the string from the pasteboard."
                isShowingAlert = true
            }
        } else {
            alertMessage = "No strings found in the pasteboard."
            isShowingAlert = true
        }
    }
}

struct CustomScannerView: View {
    let codeTypes: [AVMetadataObject.ObjectType]
    let completion: (Result<ScanResult, ScanError>) -> Void
    let pasteAction: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            CodeScannerView(codeTypes: codeTypes, completion: completion)

            Button(action: pasteAction) {
                Text("Paste Address")
                    .padding()
                    .foregroundColor(.primary)
                    .background(Color.white.opacity(0.5))
                    .clipShape(Capsule())

            }
            .padding(.bottom, 20)
        }
    }
}

#if DEBUG
    #Preview {
        AddressView(
            amount: "200",
            address: "tb1pw6y0vtmsn46epvz0j8ddc46ketmp28t82p22hcrrkch3a0jhu40qe267dl",
            navigationPath: .constant(NavigationPath())
        )
    }
    #Preview {
        AddressView(
            amount: "200",
            address: "tb1pw6y0vtmsn46epvz0j8ddc46ketmp28t82p22hcrrkch3a0jhu40qe267dl",
            navigationPath: .constant(NavigationPath())
        )
        .environment(\.dynamicTypeSize, .accessibility5)
    }
#endif
