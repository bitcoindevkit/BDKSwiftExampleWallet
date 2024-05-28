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

extension String {
    func hexStringToByteArray() -> [UInt8] {
        var startIndex = self.startIndex
        var byteArray: [UInt8] = []

        while startIndex < self.endIndex {
            let endIndex =
                self.index(startIndex, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
            let byteString = self[startIndex..<endIndex]
            if let byte = UInt8(byteString, radix: 16) {
                byteArray.append(byte)
            } else {
                return []
            }
            startIndex = endIndex
        }

        return byteArray
    }
}
let transactionHexString1 =
    "0200000000010196f8853de6a1efc4462f56492471feb52d2d414a79a7b4ba8307d34e95bdeb230100000000fdffffff02b4def61100000000160014712c184fc6effa4966c9e7af861a9d457c7cc5288096980000000000160014e7539af58eadb75c33e696d1134b83e4ee097838024730440220537b326ad5036e6ec7508a95d1d1b0f7e668d2f4598a73f772c28fdaa892dda702203027e3a81cce75a53928d9c42275970a458fd374c348617fb72c3a5f2edad69e012103b7a2690a950b3b93a2c5eda262fcea5415a2caed4e663f877215a47d7edf9c85066c0d00"
let transactionHexString2 =
    "02000000000101216739c79c42520d1a33e6a94a09582d9b853a75724ccd93f350f53ac1380cc70000000000fdffffff02487f8f12000000001600143bdcf351a3687b84680c0dab21ad19d022c1397240420f0000000000160014d7bf90e821b375d90e0d0b5621eb5b58eec4b277024730440220578279631d84b7db2065fc6111b387f5f4d778965c66283ed9aabb59416bb530022000cc943fb5103101c9495ee69b37ba7e29c7a11980e073d216c8082337057247012102295e20cc75b1a25bc642d3b627264852931b576c5f55299b920be366a2845f29b56b0d00"
let mockTransactionBytes1 = transactionHexString1.hexStringToByteArray()
let mockTransactionBytes2 = transactionHexString2.hexStringToByteArray()
let mockTransaction1: Transaction? = {
    let transactionBytes = transactionHexString1.hexStringToByteArray()
    do {
        return try Transaction(transactionBytes: mockTransactionBytes1)
    } catch {
        return nil
    }
}()
let mockTransaction2: Transaction? = {
    let transactionBytes = transactionHexString2.hexStringToByteArray()
    do {
        return try Transaction(transactionBytes: mockTransactionBytes2)
    } catch {
        return nil
    }
}()
let mockCanonicalTx1 = CanonicalTx(
    transaction: mockTransaction1!,
    chainPosition: .confirmed(height: UInt32(210000), timestamp: UInt64(21000))
)
let mockCanonicalTx2 = CanonicalTx(
    transaction: mockTransaction2!,
    chainPosition: .unconfirmed(timestamp: UInt64(21000))
)

extension BitcoinDevKit.Transaction {
    var transactionID: String {
        return self.txid()
    }
}
