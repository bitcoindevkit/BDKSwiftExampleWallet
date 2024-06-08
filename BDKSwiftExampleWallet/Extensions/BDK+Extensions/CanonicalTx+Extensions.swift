//
//  CanonicalTx+Extensions.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 6/4/24.
//

import BitcoinDevKit
import Foundation

#if DEBUG
    extension CanonicalTx {
        static var mock = Self(
            transaction: .mock!,
            chainPosition: .confirmed(height: UInt32(1_127_972), timestamp: UInt64(1_716_927_886))
        )
    }
#endif
