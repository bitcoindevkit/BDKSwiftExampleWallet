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
                static let mutiny = "https://mutinynet.com/api"
                static let bdk = "http://signet.bitcoindevkit.net:3003/"
            }
//            static let signetMutiny = "https://mutinynet.com/api"
//            static let signetBDK = "http://signet.bitcoindevkit.net:3003/"
            static let testnet = "http://blockstream.info/testnet/api/"
        }
    }
}
