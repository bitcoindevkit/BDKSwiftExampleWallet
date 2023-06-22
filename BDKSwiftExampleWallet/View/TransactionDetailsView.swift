//
//  TransactionDetailsView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 6/22/23.
//

import SwiftUI
import BitcoinDevKit
struct TransactionDetailsView: View {
    let transaction: TransactionDetails
    
    var body: some View {
        VStack(spacing: 5) {
            VStack {
                if let transactionT = transaction.transaction {
                    Text("Transaction lockTime: \(transactionT.lockTime())")
                    // TODO: ask about other items
                }
            }
            VStack {
                if let fee = transaction.fee {
                    Text("Fee: \(fee)")
                }
            }
            VStack {
                if transaction.received > 0 {
                    Text("Received: \(transaction.received)")
                }
            }
            VStack {
                if transaction.sent > 0 {
                    Text("Sent: \(transaction.sent)")
                }
            }
            VStack {
                Text("Txid: ")
                Text(transaction.txid)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            VStack {
                VStack {
                    Text("Block Height: ")
                    Text(transaction.confirmationTime?.height.delimiter ?? "None")
                }
                VStack {
                    Text("Timestamp: ")
                    Text(transaction.confirmationTime?.timestamp.formattedTime ?? "None")
                }
            }
        }
        .padding()
        .font(.caption)
    }
}


struct TransactionDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionDetailsView(transaction: .init(transaction: .none, fee: nil, received: UInt64(20), sent: 21, txid: "22", confirmationTime: .none))
            .previewDisplayName("Light Mode")
        TransactionDetailsView(transaction: .init(transaction: .none, fee: nil, received: UInt64(20), sent: 21, txid: "22", confirmationTime: .none))
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Dark Mode")
    }
}
