//
//  TransactionDetails+Extensions.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 9/4/23.
//

import BitcoinDevKit
import Foundation

extension Transaction: Identifiable {
    public var id: String { self.txid() }
}

//extension TransactionDetails: Equatable {
//    public static func == (lhs: TransactionDetails, rhs: TransactionDetails) -> Bool {
//        // Compare each property for equality
//        return lhs.transaction == rhs.transaction && lhs.fee == rhs.fee
//            && lhs.received == rhs.received && lhs.sent == rhs.sent && lhs.txid == rhs.txid
//            && lhs.confirmationTime == rhs.confirmationTime
//    }
//}
//
//// Needed for placeholder view
//let mockTransactionDetail = TransactionDetails(
//    transaction: nil,
//    fee: Optional(2820),
//    received: 9_985_919,
//    sent: 10_100_000,
//    txid: "cdcc4d287e4780d25c577d4f5726c7d585625170559f0b294da20b55ffa2b009",
//    confirmationTime: Optional(
//        BlockTime(height: 178497, timestamp: 1_687_465_081)
//    )
//)
//
//#if DEBUG
//    let mockTransactionDetails =
//        [
//            TransactionDetails(
//                transaction: nil,
//                fee: Optional(2820),
//                received: 10_000_000,
//                sent: 0,
//                txid: "cdcc4d287e4780d25c577d4f5726c7d585625170559f0b294da20b55ffa2b009",
//                confirmationTime: Optional(
//                    BitcoinDevKit.BlockTime(height: 178497, timestamp: 1_687_465_081)
//                )
//            ),
//            TransactionDetails(
//                transaction: nil,
//                fee: Optional(2820),
//                received: 100000,
//                sent: 0,
//                txid: "1cd378b13f6c9ed506ef6c24337da7a36950b0b4611af070d6636ccc408f3130",
//                confirmationTime: Optional(
//                    BitcoinDevKit.BlockTime(height: 357327, timestamp: 1_693_053_486)
//                )
//            ),
//            TransactionDetails(
//                transaction: nil,
//                fee: Optional(2820),
//                received: 100000,
//                sent: 0,
//                txid: "4da9ebbb7438c5a27ee6a219d2c7568c33b4ccc0d49d9d43960227de7c7beb34",
//                confirmationTime: Optional(
//                    BitcoinDevKit.BlockTime(height: 213729, timestamp: 1_688_565_953)
//                )
//            ),
//            TransactionDetails(
//                transaction: nil,
//                fee: Optional(141),
//                received: 6250,
//                sent: 0,
//                txid: "68a1262ddbf1ce0b840b0f06429a8df04a4474e275a8707ec3e2a432b7178f44",
//                confirmationTime: Optional(
//                    BitcoinDevKit.BlockTime(height: 269233, timestamp: 1_690_301_719)
//                )
//            ),
//            TransactionDetails(
//                transaction: nil,
//                fee: Optional(141),
//                received: 74859,
//                sent: 100000,
//                txid: "6d65a5e57df85221b2c4c882e69de36ac775e57c044ffe19721a456597701459",
//                confirmationTime: Optional(
//                    BitcoinDevKit.BlockTime(height: 269189, timestamp: 1_690_300_353)
//                )
//            ),
//            TransactionDetails(
//                transaction: nil,
//                fee: Optional(2820),
//                received: 10_000_000,
//                sent: 0,
//                txid: "cddb6950ac9ac03fde059019389cc5be1f399852d5ce073a3d4d1fbb544d5f62",
//                confirmationTime: Optional(
//                    BitcoinDevKit.BlockTime(height: 172976, timestamp: 1_687_292_803)
//                )
//            ),
//            TransactionDetails(
//                transaction: nil,
//                fee: Optional(2820),
//                received: 1_000_000,
//                sent: 0,
//                txid: "320959113997ee8d9b3766d3022183e206d75646f018010b5bc87b816978257d",
//                confirmationTime: Optional(
//                    BitcoinDevKit.BlockTime(height: 172962, timestamp: 1_687_292_372)
//                )
//            ),
//            TransactionDetails(
//                transaction: nil,
//                fee: Optional(2820),
//                received: 100000,
//                sent: 0,
//                txid: "47b7b72f297c260c243ae0a7474554c709b8ea3a7090c8353e0828a9107e2cb3",
//                confirmationTime: Optional(
//                    BitcoinDevKit.BlockTime(height: 172955, timestamp: 1_687_292_152)
//                )
//            ),
//            TransactionDetails(
//                transaction: nil,
//                fee: Optional(141),
//                received: 50000,
//                sent: 0,
//                txid: "d639021c55ba7d4c2d7a15b9bda74eb7d7de3fac8c7395e6c6cbb1ff5d6541b7",
//                confirmationTime: Optional(
//                    BitcoinDevKit.BlockTime(height: 269162, timestamp: 1_690_299_514)
//                )
//            ),
//            TransactionDetails(
//                transaction: nil,
//                fee: Optional(2820),
//                received: 100000,
//                sent: 0,
//                txid: "bd83e380361e3adacea03088bc0843a6c3ec87601edaa197141fc512cd343dc2",
//                confirmationTime: Optional(
//                    BitcoinDevKit.BlockTime(height: 173003, timestamp: 1_687_293_647)
//                )
//            ),
//            TransactionDetails(
//                transaction: nil,
//                fee: Optional(141),
//                received: 87359,
//                sent: 100000,
//                txid: "2ad94edbd9b4f2794d731ec660b0f1076ed287cfee198333f7035d5861f6abe8",
//                confirmationTime: Optional(
//                    BitcoinDevKit.BlockTime(height: 269197, timestamp: 1_690_300_599)
//                )
//            ),
//        ]
//    let mockTransactionDetailsZero: [TransactionDetails] = []
//#endif
