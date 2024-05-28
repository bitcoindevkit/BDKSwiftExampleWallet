//
//  Balance+Extensions.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 9/4/23.
//

import BitcoinDevKit
import Foundation

extension Balance: Equatable {
    public static func == (lhs: Balance, rhs: Balance) -> Bool {
        return lhs.immature == rhs.immature && lhs.trustedPending == rhs.trustedPending
            && lhs.untrustedPending == rhs.untrustedPending && lhs.confirmed == rhs.confirmed
            && lhs.trustedSpendable == rhs.trustedSpendable && lhs.total == rhs.total
    }
}

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
