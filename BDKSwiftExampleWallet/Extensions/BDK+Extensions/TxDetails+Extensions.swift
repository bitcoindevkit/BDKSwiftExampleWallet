//
//  TxDetails+Extensions.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 6/11/25.
//

import Foundation
import BitcoinDevKit

extension TxDetails {
    static let mock = TxDetails(
        txid: .mock!,
        sent: .mock,
        received: .mock,
        fee: nil,
        feeRate: nil,
        balanceDelta: Int64(0),
        chainPosition: .mock,
        tx: .mock!
    )
}
