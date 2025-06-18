//
//  AppStorageUtil.swift
//  BDKSwiftExampleWallet
//
//  Created by Rubens Machion on 26/05/25.
//

import SwiftUI

struct AppStorageUtil {
    @AppStorage("isNeedFullScan") var isNeedFullScan: Bool?

    static var shared = AppStorageUtil()
}
