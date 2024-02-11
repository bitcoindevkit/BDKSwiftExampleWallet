//
//  Constants.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 6/4/23.
//

import Foundation
import SwiftUI

struct Constants {
    struct Config {
        struct EsploraServerURLNetwork {
            struct Bitcoin {
                private static let blockstream = "https://blockstream.info/api"
                private static let mempoolspace = "https://mempool.space/api"
                static let allValues = [
                    blockstream,
                    mempoolspace,
                ]
            }
            struct Regtest {
                private static let local = "http://127.0.0.1:3002"
                static let allValues = [
                    local
                ]
            }
            struct Signet {
                static let bdk = "http://signet.bitcoindevkit.net:3003/"
                static let mutiny = "https://mutinynet.com/api"
                static let allValues = [
                    bdk,
                    mutiny,
                ]
            }
            struct Testnet {
                static let blockstream = "http://blockstream.info/testnet/api/"
                static let kuutamo = "https://esplora.testnet.kuutamo.cloud"
                static let mempoolspace = "https://mempool.space/testnet/api/"
                static let allValues = [
                    blockstream,
                    kuutamo,
                    mempoolspace,
                ]
            }
        }
    }
    enum BitcoinNetworkColor {
        case bitcoin
        case regtest
        case signet
        case testnet

        var color: Color {
            switch self {
            case .regtest:
                return Color.green
            case .signet:
                return Color.yellow
            case .bitcoin:
                // Supposed to be `Color.black`
                // ... but I'm just going to make it `Color.orange`
                // ... since `Color.black` might not work well for both light+dark mode
                // ... and `Color.orange` just makes more sense to me
                return Color.orange
            case .testnet:
                return Color.red
            }
        }
    }
}
