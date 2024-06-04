//
//  Array+Extensions.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 6/4/24.
//

import Foundation

extension Array where Element == UInt8 {
    var hexString: String {
        return self.map { String(format: "%02x", $0) }.joined()
    }
}
