//
//  BDKSwiftExampleWalletError.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 6/4/23.
//

import Foundation

enum WalletError: Error {
    case blockchainConfigNotFound
    case dbNotFound
    case notSigned
    case walletNotFound
    case fullScanUnsupported
    case backendNotImplemented
}

extension WalletError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .blockchainConfigNotFound:
            return "Blockchain configuration not found"
        case .dbNotFound:
            return "Database not found"
        case .notSigned:
            return "Transaction not signed"
        case .walletNotFound:
            return "Wallet not found"
        case .fullScanUnsupported:
            return "Full scan is not supported by the selected blockchain client"
        case .backendNotImplemented:
            return "The selected blockchain backend is not yet implemented"
        }
    }
}
