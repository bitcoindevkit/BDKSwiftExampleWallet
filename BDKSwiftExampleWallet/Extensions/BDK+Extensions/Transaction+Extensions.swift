//
//  Transaction+Extensions.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 9/21/23.
//

import BitcoinDevKit

//extension BitcoinDevKit.Transaction: Equatable {
//    public static func == (lhs: BitcoinDevKit.Transaction, rhs: BitcoinDevKit.Transaction) -> Bool {
//        // Compare the properties that determine equality for Transaction
//        return lhs.txid() == rhs.txid() && lhs.weight() == rhs.weight() && lhs.size() == rhs.size()
//            && lhs.vsize() == rhs.vsize() && lhs.serialize() == rhs.serialize()
//            && lhs.isCoinBase() == rhs.isCoinBase()
//            && lhs.isExplicitlyRbf() == rhs.isExplicitlyRbf()
//            && lhs.isLockTimeEnabled() == rhs.isLockTimeEnabled() && lhs.version() == rhs.version()
//            && lhs.lockTime() == rhs.lockTime() && lhs.input() == rhs.input()
//            && lhs.output() == rhs.output()
//    }
//}

extension BitcoinDevKit.Transaction {
    var transactionID: String {
        return self.txid()
    }
}

