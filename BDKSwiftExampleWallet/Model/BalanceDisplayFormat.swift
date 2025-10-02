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

    var displayPrefix: String {
        switch self {
        case .bitcoinSats, .bitcoin, .bip177: return "₿"
        case .fiat: return "$"
        default: return ""
        }
    }

    var displayText: String {
        switch self {
        case .sats, .bitcoinSats: return "sats"
        case .bitcoin, .bip177: return ""
        //        case .bip21q: return "₿"
        case .fiat: return "USD"
        }
    }

    func formatted(_ btcAmount: UInt64, fiatPrice: Double) -> String {
        switch self {
        case .sats:
            return btcAmount.formatted(.number)
        case .bitcoin:
            return String(format: "%.8f", Double(btcAmount) / 100_000_000)
        case .bitcoinSats:
            return btcAmount.formattedSatoshis()
        case .fiat:
            let satsPrice = Double(btcAmount).valueInUSD(price: fiatPrice)
            return satsPrice.formatted(.number.precision(.fractionLength(2)))
        case .bip177:
            return btcAmount.formattedBip177()
        }
    }
}

extension BalanceDisplayFormat {
    var index: Int {
        BalanceDisplayFormat.allCases.firstIndex(of: self) ?? 0
    }
}
