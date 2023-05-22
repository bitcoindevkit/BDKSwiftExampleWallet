//
//  ContentView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 5/22/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "bitcoinsign")
                .imageScale(.large)
                .foregroundColor(.orange)
            Text("Hello, Bitcoin!")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
