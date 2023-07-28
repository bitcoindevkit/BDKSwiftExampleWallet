//
//  PriceResponse.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 7/28/23.
//

import Foundation

struct PriceResponse: Codable {
    let prices: [Price]
    let exchangeRates: [String: Double]
}

struct Price: Codable {
    let time: Int
    let USD: Double
    let EUR: Double
    let GBP: Double
    let CAD: Double
    let CHF: Double
    let AUD: Double
    let JPY: Double
}
