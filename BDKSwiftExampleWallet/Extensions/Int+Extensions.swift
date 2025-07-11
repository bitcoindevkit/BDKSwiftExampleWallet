//
//  Int+Extensions.swift
//  BDKSwiftExampleWallet
//
//  Created by Temiloluwa on 15/06/2023.
//

import Foundation

extension UInt32 {
    private static var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal

        return numberFormatter
    }()

    var delimiter: String {
        return UInt32.numberFormatter.string(from: NSNumber(value: self)) ?? ""
    }
}

extension UInt64 {
    private static var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal

        return numberFormatter
    }()

    var delimiter: String {
        return UInt64.numberFormatter.string(from: NSNumber(value: self)) ?? ""
    }
}

extension UInt64 {
    func formattedSatoshis() -> String {
        if self == 0 {
            return "0.00 000 000"
        } else {
            // Convert satoshis to BTC (1 BTC = 100,000,000 sats)
            let btcValue = Double(self) / 100_000_000.0
            
            // Format BTC value to exactly 8 decimal places
            let btcString = String(format: "%.8f", btcValue)
            
            // Split the string at the decimal point
            let parts = btcString.split(separator: ".")
            guard parts.count == 2 else { return btcString }
            
            let wholePart = String(parts[0])
            let decimalPart = String(parts[1])
            
            // Ensure decimal part is exactly 8 digits
            let paddedDecimal = decimalPart.padding(toLength: 8, withPad: "0", startingAt: 0)
            
            // Format as XX.XX XXX XXX
            let first = paddedDecimal.prefix(2)
            let second = paddedDecimal.dropFirst(2).prefix(3)
            let third = paddedDecimal.dropFirst(5).prefix(3)
            
            let formattedBalance = "\(wholePart).\(first) \(second) \(third)"

            return formattedBalance
        }
    }
}

extension Int {
    func newDateAgo() -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        let relativeDate = formatter.localizedString(for: date, relativeTo: Date.now)

        return relativeDate
    }
}

extension UInt64 {
    func toDate() -> Date {
        return Date(timeIntervalSince1970: TimeInterval(self))
    }
}
