//
//  ContentView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 5/22/23.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        
           OnboardingView()
        
        //.padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            
            ContentView()
                .preferredColorScheme(.dark)
            
            ContentView()
                .preferredColorScheme(.light)
        }
    }
}
