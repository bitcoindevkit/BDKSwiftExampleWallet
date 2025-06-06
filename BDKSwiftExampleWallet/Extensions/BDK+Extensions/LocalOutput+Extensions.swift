//
//  LocalOutput+Extensions.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/4/24.
//

import BitcoinDevKit
import Foundation

//#if DEBUG
extension LocalOutput {
    static var mock = LocalOutput(
        outpoint: OutPoint(
            txid: try! Txid.fromBytes(
                bytes: Data([
                    0xc1, 0xf9, 0xfe, 0x0d, 0x7f, 0x97, 0xc6, 0x49,
                    0x0f, 0x83, 0x60, 0xcf, 0x71, 0xbb, 0xef, 0x15,
                    0x1f, 0x2e, 0x73, 0x30, 0x2b, 0xd0, 0x6f, 0x16,
                    0x90, 0xd6, 0x40, 0xb9, 0x6f, 0xb9, 0x44, 0x57,
                ])
            ),
            vout: UInt32(1)
        ),
        txout: TxOut(
            value: .fromSat(satoshi: 1),
            scriptPubkey: Script.init(rawOutputScript: Data([0x51]))
        ),
        keychain: .external,
        isSpent: false,
        derivationIndex: UInt32(32),
        chainPosition: .unconfirmed(timestamp: nil)
    )
}
//#endif
