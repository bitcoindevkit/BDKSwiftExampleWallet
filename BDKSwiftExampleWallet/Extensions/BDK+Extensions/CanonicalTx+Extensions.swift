//
//  CanonicalTx+Extensions.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 6/4/24.
//

import BitcoinDevKit
import Foundation

//#if DEBUG
extension CanonicalTx {
    static var mock = Self(
        transaction: .mock!,
        chainPosition: .confirmed(
            confirmationBlockTime: .init(
                blockId: .init(
                    height: UInt32(12),
                    hash: try! BlockHash.fromBytes(
                        bytes: Data([
                            0xc1, 0xf9, 0xfe, 0x0d, 0x7f, 0x97, 0xc6, 0x49,
                            0x0f, 0x83, 0x60, 0xcf, 0x71, 0xbb, 0xef, 0x15,
                            0x1f, 0x2e, 0x73, 0x30, 0x2b, 0xd0, 0x6f, 0x16,
                            0x90, 0xd6, 0x40, 0xb9, 0x6f, 0xb9, 0x44, 0x57,
                        ])
                    )
                ),
                confirmationTime: UInt64(21)
            ),
            transitively: try! Txid.fromBytes(
                bytes: Data([
                    0xc1, 0xf9, 0xfe, 0x0d, 0x7f, 0x97, 0xc6, 0x49,
                    0x0f, 0x83, 0x60, 0xcf, 0x71, 0xbb, 0xef, 0x15,
                    0x1f, 0x2e, 0x73, 0x30, 0x2b, 0xd0, 0x6f, 0x16,
                    0x90, 0xd6, 0x40, 0xb9, 0x6f, 0xb9, 0x44, 0x57,
                ])
            )
        )
    )
}
//#endif
