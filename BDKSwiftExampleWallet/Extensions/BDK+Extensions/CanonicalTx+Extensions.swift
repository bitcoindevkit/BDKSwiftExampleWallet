//
//  CanonicalTx+Extensions.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 6/4/24.
//

import BitcoinDevKit
import Foundation

//#if DEBUG
extension CanonicalTx {
    static var mock = Self(
        transaction: .mock!,
        chainPosition: .confirmed(
            confirmationBlockTime: .init(
                blockId: .init(
                    height: UInt32(12),
                    hash: "hash"
                ),
                confirmationTime: UInt64(21)
            ),
            transitively: "c1f9fe0d7f97c6490f8360cf71bbef151f2e73302bd06f1690d640b96fb94457"
        )
    )
}
//#endif
