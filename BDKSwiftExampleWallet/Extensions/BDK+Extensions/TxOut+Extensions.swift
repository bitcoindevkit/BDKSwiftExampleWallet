//
//  TxOut+Extensions.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 9/21/23.
//

import BitcoinDevKit

extension TxOut: Equatable {
    public static func == (lhs: TxOut, rhs: TxOut) -> Bool {
        return lhs.value == rhs.value && lhs.scriptPubkey == rhs.scriptPubkey
    }
}
