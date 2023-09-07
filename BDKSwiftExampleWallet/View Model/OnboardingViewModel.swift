//
//  OnboardingViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/6/23.
//

import BitcoinDevKit
import Foundation
import SwiftUI

// Can't make @Observable yet
// https://developer.apple.com/forums/thread/731187
// Feature or Bug?
class OnboardingViewModel: ObservableObject {
    @AppStorage("isOnboarding") var isOnboarding: Bool?
    let bdkClient: BDKClient

    init(bdkClient: BDKClient = .live) {
        self.bdkClient = bdkClient
    }

    func createWallet() {
        do {
            try bdkClient.createWallet()
            isOnboarding = false
        } catch let error as WalletError {
            print("createWallet - Wallet Error: \(error.localizedDescription)")
        } catch {
            print("createWallet - Undefined Error: \(error.localizedDescription)")
        }
    }

    func restoreWallet() {
        do {
            try bdkClient.loadWallet()
            isOnboarding = false
        } catch let error as WalletError {
            print("restoreWallet - Wallet Error: \(error.localizedDescription)")
        } catch {
            print("restoreWallet - Undefined Error: \(error.localizedDescription)")
        }
    }

}
