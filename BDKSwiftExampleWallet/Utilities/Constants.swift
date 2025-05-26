//
//  Constants.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 6/4/23.
//

import BitcoinDevKit
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
                static let bdk = "http://signet.bitcoindevkit.net"
                static let mutiny = "https://mutinynet.com/api"
                static let mempoolspace = "https://mempool.space/signet/api"
                static let allValues = [
                    mempoolspace,
                    mutiny,
                    bdk,
                ]
            }
            struct Testnet {
                static let blockstream = "https://blockstream.info/testnet/api/"
                static let mempoolspace = "https://mempool.space/testnet/api/"
                static let allValues = [
                    mempoolspace,
                    blockstream,
                ]
            }
            struct Testnet4 {
                static let mempoolspace = "https://mempool.space/testnet4/api/"
                static let allValues = [
                    mempoolspace
                ]
            }
        }
    }
    enum BitcoinNetworkColor {
        case bitcoin
        case regtest
        case signet
        case testnet
        case testnet4

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
            case .testnet4:
                return Color.cyan
            }
        }
    }
}

extension Network {
    var url: String {
        switch self {
        case .bitcoin:
            Constants.Config.EsploraServerURLNetwork.Bitcoin.allValues.first ?? ""
        case .testnet:
            Constants.Config.EsploraServerURLNetwork.Testnet.allValues.first ?? ""
        case .signet:
            Constants.Config.EsploraServerURLNetwork.Signet.allValues.first ?? ""
        case .regtest:
            Constants.Config.EsploraServerURLNetwork.Regtest.allValues.first ?? ""
        case .testnet4:
            Constants.Config.EsploraServerURLNetwork.Testnet4.allValues.first ?? ""
        }
    }
    
    var taprootHeight: UInt32 {
        switch self {
        case .bitcoin:
            return 700_000
        default:
            return 250_000
        }
    }
}
