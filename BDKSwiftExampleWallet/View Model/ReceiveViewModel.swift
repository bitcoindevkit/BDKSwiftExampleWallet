//
//  ReceiveViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/6/23.
//

import Foundation
import Observation

@Observable
class ReceiveViewModel {
    var address: String = ""
    let bdkService: BDKServiceAPI

    init(bdkService: BDKServiceAPI = .live) {
        self.bdkService = bdkService
    }
    func getAddress() {
        do {
            let address = try bdkService.getAddress()
            self.address = address
        } catch {
            self.address = "Error getting address."
        }
    }
    
}
