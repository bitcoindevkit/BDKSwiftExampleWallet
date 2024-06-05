//
//  SentAndReceivedValues+Extensions.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 6/4/24.
//

import BitcoinDevKit
import Foundation

#if DEBUG
    extension SentAndReceivedValues {
        static var mock = Self(
            sent: Amount.fromSat(fromSat: UInt64(0)),
            received: Amount.fromSat(fromSat: UInt64(1_000_000))
        )
    }
#endif
