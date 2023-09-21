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
        immature: 0,
        trustedPending: 0,
        untrustedPending: 0,
        confirmed: 21_418_468,
        spendable: 21_418_468,
        total: 21_418_468
    )
    let mockBalanceZero = Balance(
        immature: 0,
        trustedPending: 0,
        untrustedPending: 0,
        confirmed: 21_418_468,
        spendable: 0,
        total: 0
    )
#endif
