//
//  TransactionListHeaderView.swift
//  BDKSwiftExampleWallet
//
//  Created by Rubens Machion on 24/04/25.
//

import SwiftUI

struct ActivityHomeHeaderView: View {
    
    let walletSyncState: WalletSyncState
    let progress: Float
    let inspectedScripts: UInt64
    let totalScripts: UInt64
    let needsFullScan: Bool
    
    let showAllTransactions: () -> Void
    
    var body: some View {
        HStack {
            Text("Activity")
            Spacer()
            
            HStack {
                if case let .fullSyncing(inspectedScripts) = state {
                    Text("\(inspectedScripts)")
                        .padding(.trailing, -5.0)
                        .fontWeight(.semibold)
                        .contentTransition(.numericText())
                        .transition(.opacity)
                        .fontDesign(.monospaced)
                        .foregroundStyle(.secondary)
                        .font(.caption2)
                        .fontWeight(.thin)
                        .animation(.easeInOut, value: inspectedScripts)
                }
                if case let .syncing(progress, inspectedScripts, totalScripts) = state {
                    HStack {
                        if progress < 1.0 {
                            Text("\(inspectedScripts)")
                                .padding(.trailing, -5.0)
                                .fontWeight(.semibold)
                                .contentTransition(.numericText())
                                .transition(.opacity)

                            Text("/")
                                .padding(.trailing, -5.0)
                                .transition(.opacity)
                            Text("\(totalScripts)")
                                .contentTransition(.numericText())
                                .transition(.opacity)
                        }

                        Text(
                            String(
                                format: "%.0f%%",
                                progress * 100
                            )
                        )
                        .contentTransition(.numericText())
                        .transition(.opacity)
                    }
                    .fontDesign(.monospaced)
                    .foregroundStyle(.secondary)
                    .font(.caption2)
                    .fontWeight(.thin)
                    .animation(.easeInOut, value: inspectedScripts)
                    .animation(.easeInOut, value: totalScripts)
                    .animation(.easeInOut, value: progress)
                }
            }
            HStack {
                HStack(spacing: 5) {
                    state.syncImageIndicator
                }
                .contentTransition(.symbolEffect(.replace.offUp))

            }
            .foregroundStyle(.secondary)
            .font(.caption)
            
            if case .synced = state {
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


fileprivate extension ActivityHomeHeaderView.State {
    
    var syncImageIndicator: some View {
        switch self {
        case .synced:
            return AnyView(
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            )
            
        case .syncing(_, _, _), .fullSyncing(_):
            return AnyView(
                Image(systemName: "slowmo")
                    .symbolEffect(
                        .variableColor.cumulative
                    )
            )
            
        case .notStarted:
            return AnyView(
                Image(systemName: "arrow.clockwise")
            )
        default:
            return AnyView(
                Image(
                    systemName: "person.crop.circle.badge.exclamationmark"
                )
            )
        }
    }
}
