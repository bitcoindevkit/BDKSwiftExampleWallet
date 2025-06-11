//
//  Amount+Extensions.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 5/22/24.
//

import BitcoinDevKit
import Foundation

extension Amount: @retroactive Equatable {
    public static func == (lhs: Amount, rhs: Amount) -> Bool {
        return lhs.toSat() == rhs.toSat()
    }
}

extension Amount {
    static let mock = Amount.fromSat(satoshi: 100_000)
}
