//
//  Outpoint+Extensions.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 6/3/25.
//

import Foundation
import BitcoinDevKit

extension OutPoint: Hashable {
    public static func == (lhs: OutPoint, rhs: OutPoint) -> Bool {
        lhs.txid == rhs.txid && lhs.vout == rhs.vout
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(txid)
        hasher.combine(vout)
    }
}
