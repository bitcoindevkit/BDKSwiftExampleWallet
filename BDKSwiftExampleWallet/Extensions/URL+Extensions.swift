//
//  URL+Extensions.swift
//  BDKSwiftExampleWallet
//
//  Created by Rubens Machion on 17/05/25.
//

import Foundation

extension URL {

    static var defaultWalletDirectory: URL {
        URL.documentsDirectory
    }

    static var walletDirectoryName: String {
        "wallet_data"
    }

    static var walletDBName: String {
        "wallet.sqlite"
    }

    static var walletDataDirectoryURL: URL {
        defaultWalletDirectory.appendingPathComponent(walletDirectoryName)
    }

    static var persistenceBackendPath: String {
        walletDataDirectoryURL.appendingPathComponent(walletDBName).path
    }
}
