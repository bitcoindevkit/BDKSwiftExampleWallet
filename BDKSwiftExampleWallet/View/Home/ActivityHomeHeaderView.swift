//
//  TransactionListHeaderView.swift
//  BDKSwiftExampleWallet
//
//  Created by Rubens Machion on 24/04/25.
//

import SwiftUI

struct ActivityHomeHeaderView: View {
    
    struct DataSource {
        let walletSyncState: WalletSyncState
        let progress: Float
        let inspectedScripts: UInt64
        let totalScripts: UInt64
        let needsFullScan: Bool
    }
    
    let dataSource: ActivityHomeHeaderView.DataSource
    
    let showAllTransactions: () -> Void
    
    var body: some View {
        HStack {
            Text("Activity")
            Spacer()
            if dataSource.walletSyncState == .syncing {
                HStack {
                    if dataSource.progress < 1.0 {
                        Text("\(dataSource.inspectedScripts)")
                            .padding(.trailing, -5.0)
                            .fontWeight(.semibold)
                            .contentTransition(.numericText())
                            .transition(.opacity)

                        if !dataSource.needsFullScan {
                            Text("/")
                                .padding(.trailing, -5.0)
                                .transition(.opacity)
                            Text("\(dataSource.totalScripts)")
                                .contentTransition(.numericText())
                                .transition(.opacity)
                        }
                    }

                    if !dataSource.needsFullScan {
                        Text(
                            String(
                                format: "%.0f%%",
                                dataSource.progress * 100
                            )
                        )
                        .contentTransition(.numericText())
                        .transition(.opacity)
                    }
                }
                .fontDesign(.monospaced)
                .foregroundStyle(.secondary)
                .font(.caption2)
                .fontWeight(.thin)
                .animation(.easeInOut, value: dataSource.inspectedScripts)
                .animation(.easeInOut, value: dataSource.totalScripts)
                .animation(.easeInOut, value: dataSource.progress)
            }
            HStack {
                HStack(spacing: 5) {
                    if dataSource.walletSyncState == .syncing {
                        Image(systemName: "slowmo")
                            .symbolEffect(
                                .variableColor.cumulative
                            )
                    } else if dataSource.walletSyncState == .synced {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(
                                dataSource.walletSyncState == .synced
                                    ? .green : .secondary
                            )
                    } else if dataSource.walletSyncState == .notStarted {
                        Image(systemName: "arrow.clockwise")
                    } else {
                        Image(
                            systemName: "person.crop.circle.badge.exclamationmark"
                        )
                    }
                }
                .contentTransition(.symbolEffect(.replace.offUp))

            }
            .foregroundStyle(.secondary)
            .font(.caption)

            if dataSource.walletSyncState == .synced {
                Button {
                    self.showAllTransactions()
                } label: {
                    HStack(spacing: 2) {
                        Text("Show All")
                        Image(systemName: "arrow.right")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fontWeight(.regular)
                }
            }

        }
        .fontWeight(.bold)
    }
}
