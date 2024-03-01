//
//  Balance+Extensions.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 9/4/23.
//

import BitcoinDevKit
import Foundation

#if DEBUG
//    let mockBalance = Balance(
//        immature: 0,
//        trustedPending: 0,
//        untrustedPending: 0,
//        confirmed: 21_418_468,
//        spendable: 21_418_468,
//        total: 21_418_468
//    )
//    let mockBalanceZero = Balance(
//        immature: 0,
//        trustedPending: 0,
//        untrustedPending: 0,
//        confirmed: 21_418_468,
//        spendable: 0,
//        total: 0
//    )
let mockBalance = Balance(
    immature: UInt64(1),
    trustedPending: UInt64(1),
    untrustedPending: UInt64(1),
    confirmed: UInt64(1),
    trustedSpendable: UInt64(1),
    total: UInt64(1000)
)

let mockBalanceZero = Balance(
    immature: UInt64(0),
    trustedPending: UInt64(0),
    untrustedPending: UInt64(0),
    confirmed: UInt64(1),
    trustedSpendable: UInt64(1),
    total: UInt64(1000)
)
#endif
