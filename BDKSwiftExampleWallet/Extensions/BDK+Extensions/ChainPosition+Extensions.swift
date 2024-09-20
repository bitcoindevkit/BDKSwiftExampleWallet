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
            return timestamp1 < timestamp2
        case (.confirmed(let blockTime1), .confirmed(let blockTime2)):
            // If both are confirmed, compare by block height descending.
            return blockTime1.blockId.height > blockTime2.blockId.height
        }
    }
}
