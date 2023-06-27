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
            
            // Need
            VStack {
                if let fee = transaction.fee {
                    Text("Fee: \(fee)")
                }
            }
            
            // TODO: I need to subtract sent from received and if its negative it was a send and if its positive it was a receive
            // this is because of change amounts
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

            // TODO: add copy button
            // Need,
            VStack {
                Text("Txid: ")
                Text(transaction.txid)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            
            // TODO: if block time is nil its unconfirmed, if its not null its confirmed
            // Need
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
