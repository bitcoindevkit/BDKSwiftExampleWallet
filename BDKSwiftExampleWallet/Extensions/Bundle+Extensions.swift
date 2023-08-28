//
//  Bundle+Extensions.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/22/23.
//

import Foundation

extension Bundle {
    var displayName: String {
        return Bundle.main.infoDictionary?["CFBundleName"] as? String ?? Bundle.main
            .bundleIdentifier ?? "Unknown Bundle"
    }
}
