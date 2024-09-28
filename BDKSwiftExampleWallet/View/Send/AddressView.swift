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
    @Binding var navigationPath: NavigationPath
    @State var address: String = ""
    @State private var isShowingAlert = false
    @State private var alertMessage = ""
    let pasteboard = UIPasteboard.general

    var body: some View {

        ZStack {
            Color(uiColor: .systemBackground)

            CustomScannerView(
                codeTypes: [.qr],
                completion: handleScan,
                pasteAction: pasteAddress
            )
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
        switch result {
        case .success(let result):
            let scannedAddress = result.string.lowercased().replacingOccurrences(
                of: "bitcoin:",
                with: ""
            )
            let components = scannedAddress.components(separatedBy: "?")
            if let bitcoinAddress = components.first {
                address = bitcoinAddress
                navigationPath.append(NavigationDestination.amount(address: bitcoinAddress))
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
        if let pasteboardContent = UIPasteboard.general.string {
            if pasteboardContent.isEmpty {
                alertMessage = "The pasteboard is empty."
                isShowingAlert = true
                return
            }
            let trimmedContent = pasteboardContent.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedContent.isEmpty {
                alertMessage = "The pasteboard contains only whitespace."
                isShowingAlert = true
                return
            }
            let lowercaseAddress = trimmedContent.lowercased()
            address = lowercaseAddress
            navigationPath.append(NavigationDestination.amount(address: address))
        } else {
            alertMessage = "Unable to access the pasteboard. Please try copying the address again."
            isShowingAlert = true
        }
    }
}

struct CustomScannerView: View {
    let codeTypes: [AVMetadataObject.ObjectType]
    let completion: (Result<ScanResult, ScanError>) -> Void
    let pasteAction: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                CodeScannerView(
                    codeTypes: codeTypes,
                    shouldVibrateOnSuccess: true,
                    completion: completion
                )
                .edgesIgnoringSafeArea(.all)

                VStack {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .bold))
                                .frame(width: 44, height: 44)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        .padding(.top, 50)
                        .padding(.leading, 20)

                        Spacer()
                    }

                    Spacer()

                    Button {
                        pasteAction()
                    } label: {
                        Text("Paste Address")
                            .padding()
                            .foregroundColor(Color(uiColor: .label))
                            .background(Color(uiColor: .systemBackground).opacity(0.5))
                            .clipShape(Capsule())
                    }
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 40)
                }
            }
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.all)
    }
}

#if DEBUG
    #Preview {
        AddressView(
            navigationPath: .constant(.init()),
            address: "tb1pw6y0vtmsn46epvz0j8ddc46ketmp28t82p22hcrrkch3a0jhu40qe267dl"
        )
    }
#endif
