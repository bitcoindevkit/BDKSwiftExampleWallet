//
//  ReceiveViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/6/23.
//

import Foundation

class ReceiveViewModel: ObservableObject {
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
