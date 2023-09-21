//
//  Constants.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 6/4/23.
//

import Foundation

struct Constants {
    struct Config {
        struct EsploraServerURLNetwork {
            struct Signet {
                static let bdk = "http://signet.bitcoindevkit.net:3003/"
                static let mutiny = "https://mutinynet.com/api"
            }
            struct Testnet {
                static let blockstream = "http://blockstream.info/testnet/api/"
                static let mempool = "https://mempool.space/testnet/api/"
            }
        }
    }
}
