//
//  AppStorageUtil.swift
//  BDKSwiftExampleWallet
//
//  Created by Rubens Machion on 26/05/25.
//

import SwiftUI

struct StorageUtil {
    @AppStorage("isNeedFullScan") var isNeedFullScan: Bool?

    static var shared = StorageUtil()
}
