//
//  Double+Extensions.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 7/28/23.
//

import Foundation

extension Double {
    func formattedPrice(currencyCode: CurrencyCode) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencyCode = currencyCode.rawValue
        
        return numberFormatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
    func valueInUSD(price: Double) -> String {
        let bitcoin = self / 100000000.0 // Convert satoshis to bitcoin
        let usdValue = bitcoin * price
        return usdValue.formattedPrice(currencyCode: .USD)
    }
}
