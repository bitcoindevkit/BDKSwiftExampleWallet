//
//  OnboardingViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/6/23.
//

import Foundation
import BitcoinDevKit
import SwiftUI

// Can't make @Observable yet
// https://developer.apple.com/forums/thread/731187
// Feature or Bug?
class OnboardingViewModel: ObservableObject {
    @AppStorage("isOnboarding") var isOnboarding: Bool?
    let bdkService: BDKServiceAPI

    init(bdkService: BDKServiceAPI = .live) {
        self.bdkService = bdkService
    }
    
    func createWallet() {
        do {
            try bdkService.createWallet()//BDKService.shared.createWallet()
            isOnboarding = false
        } catch let error as WalletError {
            print("createWallet - Wallet Error: \(error.localizedDescription)")
        } catch {
            print("createWallet - Undefined Error: \(error.localizedDescription)")
        }
    }
    
    func restoreWallet() {
        do {
            try bdkService.loadWallet()//BDKService.shared.loadWalletFromBackup()
        } catch let error as WalletError {
            print("restoreWallet - Wallet Error: \(error.localizedDescription)")
        } catch {
            print("restoreWallet - Undefined Error: \(error.localizedDescription)")
        }
    }
    
}
