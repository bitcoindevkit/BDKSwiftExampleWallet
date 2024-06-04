//
//  Transaction+Extensions.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 9/21/23.
//

import BitcoinDevKit

extension Transaction: Identifiable {
    public var id: String { self.txid() }
}

extension BitcoinDevKit.Transaction {
    var transactionID: String {
        return self.txid()
    }
}

let transactionHexString1 =
    "01000000000101604350f234b3b4b5fde5513ff89d222e91cabf452182ba0b8d076cf08a3813a30100000000ffffffff0240420f0000000000225120c8b7757fff5ceb41908a43bfadf749afbb97b50ece0896e88f2cd14f90844d7b8df6731d00000000225120ff38f143374565d74648006f8aabef9dad548344549d8516177ff613e26f7d360140298823f597d3cb7f4934a5ef0b1814e2ca8caa9f9da0a0b59a73922d98f83ec62587add48e3fa0d0b7cf704b2fce0277e2a70f9aed8a41f2823b810b92e0421d00000000"
let mockTransactionBytes1 = transactionHexString1.hexStringToByteArray()
let mockTransaction1: Transaction? = {
    let transactionBytes = transactionHexString1.hexStringToByteArray()
    do {
        return try Transaction(transactionBytes: mockTransactionBytes1)
    } catch {
        return nil
    }
}()
let mockCanonicalTx1 = CanonicalTx(
    transaction: mockTransaction1!,
    chainPosition: .confirmed(height: UInt32(1_127_972), timestamp: UInt64(1_716_927_886))
)
