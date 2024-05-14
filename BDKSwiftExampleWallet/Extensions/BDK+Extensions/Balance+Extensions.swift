//
//  Balance+Extensions.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 9/4/23.
//

import BitcoinDevKit
import Foundation

#if DEBUG
    let mockBalance = Balance(
        immature: Amount.fromSat(fromSat: UInt64(1)),
        trustedPending: Amount.fromSat(fromSat: UInt64(1)),
        untrustedPending: Amount.fromSat(fromSat: UInt64(1)),
        confirmed: Amount.fromSat(fromSat: UInt64(1)),
        trustedSpendable: Amount.fromSat(fromSat: UInt64(1)),
        total: Amount.fromSat(fromSat: UInt64(1000))
    )

    let mockBalanceZero = Balance(
        immature: Amount.fromSat(fromSat: UInt64(0)),
        trustedPending: Amount.fromSat(fromSat: UInt64(0)),
        untrustedPending: Amount.fromSat(fromSat: UInt64(0)),
        confirmed: Amount.fromSat(fromSat: UInt64(1)),
        trustedSpendable: Amount.fromSat(fromSat: UInt64(1)),
        total: Amount.fromSat(fromSat: UInt64(1000))
    )
#endif
