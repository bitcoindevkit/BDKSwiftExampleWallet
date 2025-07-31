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
    struct Networks {
        struct Bitcoin {
            static let esploraServers = [
                "https://mempool.space/api",
                "https://blockstream.info/api",
            ]
        }

        struct Testnet {
            static let esploraServers = [
                "https://mempool.space/testnet/api/",
                "https://blockstream.info/testnet/api/",
            ]
        }

        struct Testnet4 {
            static let esploraServers = [
                "https://mempool.space/testnet4/api/"
            ]

            enum Faucet: String, CaseIterable {
                case mempool = "https://mempool.space/testnet4/faucet"

                var url: URL? { URL(string: self.rawValue) }

                var displayName: String {
                    switch self {
                    case .mempool: return "Mempool Faucet"
                    }
                }
            }
        }

        struct Regtest {
            static let esploraServers = [
                "http://127.0.0.1:3002"
            ]
        }

        struct Signet {
            struct Regular {
                static let esploraServers = [
                    "https://mempool.space/signet/api"
                ]

                enum Faucet: String, CaseIterable {
                    case bublina = "https://signet25.bublina.eu.org/"
                    case signetfaucet = "https://signetfaucet.com"

                    var url: URL? { URL(string: self.rawValue) }

                    var displayName: String {
                        switch self {
                        case .bublina: return "Bublina Faucet"
                        case .signetfaucet: return "Signet Faucet"
                        }
                    }
                }

                static let kyotoPeerStrings = [
                    "seed.signet.bitcoin.sprovoost.nl:38333",
                    "signet-seed.achownodes.xyz:38333",
                    "vrajjeirttkmnt32wpy3cowmnwr13fkla7hpxc4okr3ysd3kqtzmqd.onion:38333",
                ]

                static let kyotoPeers = [
                    // seed.signet.bitcoin.sprovoost.nl:38333 -> 45.79.52.207:38333
                    Peer(
                        address: IpAddress.fromIpv4(q1: 45, q2: 79, q3: 52, q4: 207),
                        port: 38333,
                        v2Transport: false
                    ),
                    // signet-seed.achownodes.xyz:38333 -> 192.3.169.35:38333
                    Peer(
                        address: IpAddress.fromIpv4(q1: 192, q2: 3, q3: 169, q4: 35),
                        port: 38333,
                        v2Transport: false
                    ),
                ]
            }

            struct Mutiny {
                static let esploraServers = [
                    "https://mutinynet.com/api"
                ]

                enum Faucet: String, CaseIterable {
                    case mutiny = "https://faucet.mutinynet.com"

                    var url: URL? { URL(string: self.rawValue) }

                    var displayName: String {
                        switch self {
                        case .mutiny: return "Mutiny Faucet"
                        }
                    }
                }
            }

            // Convenience computed properties for backward compatibility
            static var allEsploraServers: [String] {
                Mutiny.esploraServers + Regular.esploraServers
            }
        }
    }

    struct Config {
        struct Kyoto {
            static let dbDirectoryName = "kyoto"

            static var dbDirectoryURL: URL {
                URL.walletDataDirectoryURL.appendingPathComponent(dbDirectoryName)
            }

            static var dbPath: String {
                dbDirectoryURL.path
            }

            static func getDefaultPeer(for network: Network) -> String {
                switch network {
                case .signet:
                    return Networks.Signet.Regular.kyotoPeerStrings.first
                        ?? "seed.signet.bitcoin.sprovoost.nl:38333"
                default:
                    // Kyoto only supports Signet for now
                    return Networks.Signet.Regular.kyotoPeerStrings.first
                        ?? "seed.signet.bitcoin.sprovoost.nl:38333"
                }
            }
        }

        enum SignetNetwork {
            case regular
            case custom

            var defaultFaucet: URL? {
                switch self {
                case .regular:
                    return Networks.Signet.Regular.Faucet.bublina.url
                case .custom:
                    return Networks.Signet.Mutiny.Faucet.mutiny.url
                }
            }

            static func from(esploraURL: String) -> SignetNetwork {
                return Networks.Signet.Mutiny.esploraServers.contains(esploraURL)
                    ? .custom : .regular
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
            Constants.Networks.Bitcoin.esploraServers.first ?? ""
        case .testnet:
            Constants.Networks.Testnet.esploraServers.first ?? ""
        case .signet:
            Constants.Networks.Signet.allEsploraServers.first ?? ""
        case .regtest:
            Constants.Networks.Regtest.esploraServers.first ?? ""
        case .testnet4:
            Constants.Networks.Testnet4.esploraServers.first ?? ""
        }
    }
}
