//
//  AppStorage.swift
//  BDKSwiftExampleWallet
//
//  Created by Rubens Machion on 24/05/25.
//

import SwiftUI

struct StorageUtil {
    @AppStorage("isOnboarding") var isOnboarding: Bool?
    @AppStorage("isNeedFullScan") var isNeedFullScan: Bool?
    @AppStorage("balanceDisplayFormat") var balanceFormat: BalanceDisplayFormat =
        .bitcoinSats
    
    static var shared = StorageUtil()
}
