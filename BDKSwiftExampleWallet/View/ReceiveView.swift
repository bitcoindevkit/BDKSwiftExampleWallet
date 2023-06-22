//
//  ReceiveView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 6/20/23.
//

import SwiftUI

class ReceiveViewModel: ObservableObject {
    // Address
    @Published var address: String = ""
    
    func getAddress() {
        do {
            let address = try BDKService.shared.getAddress()
            self.address = address
        } catch {
            self.address = "Error getting address."
        }
    }
    
}


struct ReceiveView: View {
    @ObservedObject var viewModel: ReceiveViewModel
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
                        .font(.headline)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    
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
                        .bold()
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

struct ReceiveView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiveView(viewModel: .init())
            .previewDisplayName("Light Mode")
        ReceiveView(viewModel: .init())
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Dark Mode")
    }
}
