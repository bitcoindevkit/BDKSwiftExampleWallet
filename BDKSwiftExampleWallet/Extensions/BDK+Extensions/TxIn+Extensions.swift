//
//  TxIn+Extensions.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 9/21/23.
//

import BitcoinDevKit

extension TxIn: Equatable {
    public static func == (lhs: TxIn, rhs: TxIn) -> Bool {
        return lhs.previousOutput == rhs.previousOutput &&
               lhs.scriptSig == rhs.scriptSig &&
               lhs.sequence == rhs.sequence &&
               lhs.witness == rhs.witness
    }
}
