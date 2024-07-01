//
//  BDKSwiftExampleWalletError.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 6/4/23.
//

import Foundation

enum WalletError: Error {
    case walletNotFound
    case blockchainConfigNotFound
    case dbNotFound
}
