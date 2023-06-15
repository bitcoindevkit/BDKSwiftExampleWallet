//
//  Int+Extensions.swift
//  BDKSwiftExampleWallet
//
//  Created by Temiloluwa on 15/06/2023.
//

import Foundation

extension UInt64 {
    private static var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal

        return numberFormatter
    }()

    var delimiter: String {
        return UInt64.numberFormatter.string(from: NSNumber(value: self)) ?? ""
    }
}
