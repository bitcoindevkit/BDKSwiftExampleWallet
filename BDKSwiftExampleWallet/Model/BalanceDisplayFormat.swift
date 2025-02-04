//
//  BalanceDisplayFormat.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 2/3/25.
//

import Foundation

enum BalanceDisplayFormat: String, CaseIterable, Codable {
    case sats = "sats"
    case bitcoinSats = "bitcoinSats"
    case bitcoin = "btc"
    case fiat = "usd"

    var displayText: String {
        switch self {
        case .sats, .bitcoinSats: return "sats"
        case .bitcoin: return ""
        case .fiat: return "USD"
        }
    }
}

extension BalanceDisplayFormat {
    var index: Int {
        BalanceDisplayFormat.allCases.firstIndex(of: self) ?? 0
    }
}
