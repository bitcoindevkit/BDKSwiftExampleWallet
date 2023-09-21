//
//  WalletSyncState.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 9/21/23.
//

import Foundation

enum WalletSyncState: CustomStringConvertible, Equatable {
    case error(Error)
    case notStarted
    case synced
    case syncing

    var description: String {
        switch self {
        case .error(let error):
            return "Error Syncing: \(error.localizedDescription)"
        case .notStarted:
            return "Not Started"
        case .synced:
            return "Synced"
        case .syncing:
            return "Syncing"
        }
    }

    static func == (lhs: WalletSyncState, rhs: WalletSyncState) -> Bool {
        switch (lhs, rhs) {
        case (.error(let error1), .error(let error2)):
            return error1.localizedDescription == error2.localizedDescription
        case (.notStarted, .notStarted):
            return true
        case (.synced, .synced):
            return true
        case (.syncing, .syncing):
            return true
        default:
            return false
        }
    }
}
