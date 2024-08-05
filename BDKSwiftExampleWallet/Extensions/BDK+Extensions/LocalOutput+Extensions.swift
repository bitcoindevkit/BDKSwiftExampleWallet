//
//  LocalOutput+Extensions.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/4/24.
//

import BitcoinDevKit

//#if DEBUG
extension LocalOutput {
    static var mock = LocalOutput(
        outpoint: OutPoint(
            txid: "txid",
            vout: UInt32(1)
        ),
        txout: TxOut(
            value: UInt64(1),
            scriptPubkey: Script(rawOutputScript: [UInt8(1)])
        ),
        keychain: .external,
        isSpent: false
    )
}
//#endif
