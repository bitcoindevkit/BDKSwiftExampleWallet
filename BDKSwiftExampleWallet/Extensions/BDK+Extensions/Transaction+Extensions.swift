//
//  Transaction+Extensions.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 9/21/23.
//

import BitcoinDevKit
import Foundation

extension Transaction {
    var transactionID: String {
        return "\(self.computeTxid())"
    }
}

//#if DEBUG
extension Transaction {
    static var mock = try? Transaction(
        transactionBytes: Data(String.mockTransactionHex.hexStringToByteArray())
    )
}
//#endif
