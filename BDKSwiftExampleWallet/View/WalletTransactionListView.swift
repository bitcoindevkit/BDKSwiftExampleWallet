//
//  WalletTransactionListView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/6/23.
//

import SwiftUI
import BitcoinDevKit

struct WalletTransactionListView: View {
    let transactionDetails: [TransactionDetails]
    
    var body: some View {
        List {
            ForEach(
                transactionDetails.sorted(//viewModel.transactionDetails.sorted(
                    by: {
                        $0.confirmationTime?.timestamp ?? $0.received > $1.confirmationTime?.timestamp ?? $1.received
                    }
                ),
                id: \.txid
            ) { transaction in
                
                NavigationLink(
                    destination: TransactionDetailsView(
                        transaction: transaction,
                        amount:
                            transaction.sent > 0 ?
                        transaction.sent - transaction.received :
                            transaction.received - transaction.sent
                    )
                ) {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 40, height: 40)
                            Image(systemName:
                                    transaction.sent > 0 ?
                                  "arrow.up" :
                                    "arrow.down"
                            )
                            .frame(width: 20, height: 20)
                        }
                        VStack(alignment: .leading, spacing: 1){
                            Text(transaction.txid)
                                .truncationMode(.middle)
                                .lineLimit(1)
                            Text(
                                transaction.sent > 0 ?
                                "Sent" :
                                    "Received"
                            )
                            .foregroundColor(.secondary)
                        }
                        .padding(.trailing, 40.0)
                        Spacer()
                        Text(
                            transaction.sent > 0 ?
                            "- \(transaction.sent - transaction.received) sats" :
                                "+ \(transaction.received - transaction.sent) sats"
                        )
                        .font(.caption)
                    }
                }
                
            }
        }
        .listStyle(.plain)
    }
}

struct WalletTransactionListView_Previews: PreviewProvider {
    static var previews: some View {
        WalletTransactionListView(transactionDetails: [])
    }
}
