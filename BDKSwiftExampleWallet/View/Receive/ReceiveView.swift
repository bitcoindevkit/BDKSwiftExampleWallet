//
//  ReceiveView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 6/20/23.
//

import BitcoinUI
import CoreNFC
import SwiftUI

struct ReceiveView: View {
    @Bindable var viewModel: ReceiveViewModel
    @State private var isCopied = false
    @State private var showCheckmark = false
    var isSmallDevice: Bool {
        UIScreen.main.isPhoneSE
    }

    var body: some View {

        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack {

                HStack {
                    Spacer()
                    Button {
                        viewModel.startNFCSession()
                    } label: {
                        Image(systemName: "wave.3.right")
                            .foregroundColor(.primary)
                    }
                }
                .padding(.trailing)
                .padding(.top)

                VStack(spacing: 8) {
                    Image("bitcoinsign.arrow.down")
                        .symbolRenderingMode(.hierarchical)
                        .font(isSmallDevice ? .caption : .title)
                    Text("Receive")
                        .fontWeight(.semibold)
                }
                .font(.caption)
                .padding(.top, isSmallDevice ? 20.0 : 40.0)

                Spacer()

                if viewModel.address != "" {
                    QRCodeView(qrCodeType: .bitcoin(viewModel.address))
                        .animation(.default, value: viewModel.address)
                } else {
                    QRCodeView(qrCodeType: .bitcoin(viewModel.address))
                        .blur(radius: 15)
                }

                Spacer()

                AddressFormattedView(
                    address: viewModel.address,
                    columns: 4,
                    spacing: isSmallDevice ? 5.0 : 20.0,
                    gridItemSize: 60.0
                )
                .padding()

                HStack {
                    Button {
                        UIPasteboard.general.string = viewModel.address
                        isCopied = true
                        showCheckmark = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            isCopied = false
                            showCheckmark = false
                        }
                    } label: {
                        HStack {
                            Text(viewModel.address)
                                .lineLimit(1)
                                .truncationMode(.middle)
                                .fontDesign(.monospaced)
                            withAnimation {
                                Image(
                                    systemName: showCheckmark
                                        ? "document.on.document.fill" : "document.on.document"
                                )
                                .contentTransition(.symbolEffect(.replace))
                            }
                        }
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    }
                }
                .padding()
                .fontDesign(.monospaced)
                .font(.caption)

            }
            .padding()
            .onAppear {
                viewModel.getAddress()
            }

        }
        .alert(isPresented: $viewModel.showingReceiveViewErrorAlert) {
            Alert(
                title: Text("Receive Error"),
                message: Text(viewModel.receiveViewError?.description ?? "Unknown"),
                dismissButton: .default(Text("OK")) {
                    viewModel.receiveViewError = nil
                }
            )
        }

    }

}

#if DEBUG
    #Preview("ReceiveView - en") {
        ReceiveView(viewModel: .init(bdkClient: .mock))
    }
#endif
