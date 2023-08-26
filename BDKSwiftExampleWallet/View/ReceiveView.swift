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
                
                if viewModel.address != "" {
                    QRCodeView(address: viewModel.address)
                        .animation(.default, value: viewModel.address)
                } else {
                    QRCodeView(address: viewModel.address)
                        .blur(radius: 15)
                }
                
                HStack {
                    
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
                                    .font(.headline)
                            }
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(.bitcoinOrange)
                    }
                    
                }
                .padding()
                
            }
            .padding()
            .onAppear {
                viewModel.getAddress()
            }
            
        }
        
    }
    
}

#Preview("ReceiveView - en") {
    ReceiveView(viewModel: .init())
}

#Preview("ReceiveView - fr") {
    ReceiveView(viewModel: .init())
        .environment(\.locale, .init(identifier: "fr"))
}
