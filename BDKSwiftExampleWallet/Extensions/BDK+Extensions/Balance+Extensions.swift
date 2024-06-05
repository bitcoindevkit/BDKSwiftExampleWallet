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
    extension Balance {
        static var mock = Self(
            immature: Amount.fromSat(fromSat: UInt64(100)),
            trustedPending: Amount.fromSat(fromSat: UInt64(200)),
            untrustedPending: Amount.fromSat(fromSat: UInt64(300)),
            confirmed: Amount.fromSat(fromSat: UInt64(21000)),
            trustedSpendable: Amount.fromSat(fromSat: UInt64(1_000_000)),
            total: Amount.fromSat(fromSat: UInt64(615_000_000))
        )
    }
#endif
