//
//  BalanceDisplayFormat.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 2/3/25.
//

import Foundation

enum BalanceDisplayFormat: String, CaseIterable, Codable {
    case bitcoinSats = "bitcoinSats"
    case bitcoin = "btc"
    case sats = "sats"
//    case bip21q = "bip21q"
    case fiat = "usd"
    case bip177 = "bip177"

    var displayText: String {
        switch self {
        case .sats, .bitcoinSats: return "sats"
        case .bitcoin, .bip177: return ""
//        case .bip21q: return "₿"
        case .fiat: return "USD"
        }
    }
}

extension BalanceDisplayFormat {
    var index: Int {
        BalanceDisplayFormat.allCases.firstIndex(of: self) ?? 0
    }
}
