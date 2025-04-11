//
//  Network+Extensions.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 9/4/23.
//

import BitcoinDevKit
import Foundation

extension Network {
    var description: String {
        switch self {
        case .bitcoin: return "bitcoin"
        case .testnet: return "testnet"
        case .testnet4: return "testnet4"
        case .signet: return "signet"
        case .regtest: return "regtest"
        }
    }

    init?(stringValue: String) {
        switch stringValue {
        case "bitcoin": self = .bitcoin
        case "testnet": self = .testnet
        case "testnet4": self = .testnet4
        case "signet": self = .signet
        case "regtest": self = .regtest
        default: return nil
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
}

#if DEBUG
    let mockKeyClientNetwork = Network.regtest
#endif
