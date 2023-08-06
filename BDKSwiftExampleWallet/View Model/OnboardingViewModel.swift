//
//  OnboardingViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/6/23.
//

import Foundation
import BitcoinDevKit
import SwiftUI

class OnboardingViewModel: ObservableObject {
    @AppStorage("isOnboarding") var isOnboarding: Bool?
    
    func createWallet() {
        do {
            try BDKService.shared.createWallet()
            isOnboarding = false
        } catch let error as WalletError {
            print("createWallet - Wallet Error: \(error.localizedDescription)")
        } catch {
            print("createWallet - Undefined Error: \(error.localizedDescription)")
        }
    }
    
    func restoreWallet() {
        do {
            try BDKService.shared.loadWalletFromBackup()
        } catch let error as WalletError {
            print("restoreWallet - Wallet Error: \(error.localizedDescription)")
        } catch {
            print("restoreWallet - Undefined Error: \(error.localizedDescription)")
        }
    }
    
}
