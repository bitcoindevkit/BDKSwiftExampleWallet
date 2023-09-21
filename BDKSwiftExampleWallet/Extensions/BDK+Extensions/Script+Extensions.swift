//
//  Script+Extensions.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 9/21/23.
//

import BitcoinDevKit

extension Script: Equatable {
    public static func == (lhs: Script, rhs: Script) -> Bool {
        let lhsBytes = lhs.toBytes()
        let rhsBytes = rhs.toBytes()

        return lhsBytes == rhsBytes
    }
}
