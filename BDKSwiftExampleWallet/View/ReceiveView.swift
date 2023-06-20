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

    var body: some View {
        
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
            
            VStack {
                Text("Address")
                Text(viewModel.address)
                    .font(.caption)
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
