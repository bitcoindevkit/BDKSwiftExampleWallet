//
//  ReceiveView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 6/20/23.
//

import SwiftUI

struct ReceiveView: View {
    @Bindable var viewModel: ReceiveViewModel
    @State private var isCopied = false
    @State private var showCheckmark = false

    var body: some View {

        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack {

                VStack(spacing: 8) {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .resizable()
                        .foregroundColor(.bitcoinOrange)
                        .fontWeight(.bold)
                        .frame(width: 50, height: 50, alignment: .center)
                    Text("Receive Address")
                        .fontWeight(.semibold)
                }
                .font(.caption)
                .padding(.top, 40.0)

                Spacer()

                if viewModel.address != "" {
                    QRCodeView(address: viewModel.address)
                        .animation(.default, value: viewModel.address)
                } else {
                    QRCodeView(address: viewModel.address)
                        .blur(radius: 15)
                }

                Spacer()

                HStack {

                    Text("Address".uppercased())
                        .foregroundColor(.secondary)
                        .fontWeight(.light)
                    
                    Text(viewModel.address)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .fontDesign(.monospaced)

                    Button {
                        UIPasteboard.general.string = viewModel.address
                        isCopied = true
                        showCheckmark = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isCopied = false
                            showCheckmark = false
                        }
                    } label: {
                        HStack {
                            withAnimation {
                                Image(systemName: showCheckmark ? "checkmark" : "doc.on.doc")
                            }
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(.bitcoinOrange)
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

    }

}

#Preview("ReceiveView - en"){
    ReceiveView(viewModel: .init(bdkClient: .mock))
}

#Preview("ReceiveView - fr"){
    ReceiveView(viewModel: .init(bdkClient: .mock))
        .environment(\.locale, .init(identifier: "fr"))
}
