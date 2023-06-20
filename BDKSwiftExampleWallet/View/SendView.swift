//
//  SendView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 6/20/23.
//

import SwiftUI

class SendViewModel: ObservableObject {}

struct SendView: View {
    @ObservedObject var viewModel: SendViewModel

    var body: some View {
        
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
            
            VStack {
                Text("Send")
            }
            .padding()
            
        }
        
    }
    
}

struct SendView_Previews: PreviewProvider {
    static var previews: some View {
        SendView(viewModel: .init())
            .previewDisplayName("Light Mode")
        SendView(viewModel: .init())
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Dark Mode")
    }
}
