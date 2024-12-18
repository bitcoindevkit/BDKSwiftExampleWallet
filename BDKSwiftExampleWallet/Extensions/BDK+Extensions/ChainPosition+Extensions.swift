//
//  ChainPosition+Extensions.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 9/19/24.
//

import BitcoinDevKit
import Foundation

extension ChainPosition {
    func isBefore(_ other: ChainPosition) -> Bool {
        switch (self, other) {
        case (.unconfirmed, .confirmed):
            // Unconfirmed should come before confirmed.
            return true
        case (.confirmed, .unconfirmed):
            // Confirmed should come after unconfirmed.
            return false
        case (.unconfirmed(let timestamp1), .unconfirmed(let timestamp2)):
            // If both are unconfirmed, compare by timestamp (optional).
            return (timestamp1 ?? 0) < (timestamp2 ?? 0)
        case (
            .confirmed(let blockTime1, let transitively1),
            .confirmed(let blockTime2, let transitively2)
        ):
            // Sort by height descending, but note that if transitively is Some,
            // this block height might not be the "original" confirmation block
            return blockTime1.blockId.height != blockTime2.blockId.height
                ? blockTime1.blockId.height > blockTime2.blockId.height
                : (transitively1 != nil) && (transitively2 == nil)
        }
    }
}
