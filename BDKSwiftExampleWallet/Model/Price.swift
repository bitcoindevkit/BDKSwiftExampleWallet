//
//  Price.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 7/28/23.
//

import Foundation

struct Price: Codable, Equatable {
    let time: Int
    let usd: Double
    let eur: Double
    let gbp: Double
    let cad: Double
    let chf: Double
    let aud: Double
    let jpy: Double

    enum CodingKeys: String, CodingKey {
        case time
        case usd = "USD"
        case eur = "EUR"
        case gbp = "GBP"
        case cad = "CAD"
        case chf = "CHF"
        case aud = "AUD"
        case jpy = "JPY"
    }

    static func == (lhs: Price, rhs: Price) -> Bool {
        return lhs.time == rhs.time && lhs.usd == rhs.usd && lhs.eur == rhs.eur
            && lhs.gbp == rhs.gbp && lhs.cad == rhs.cad && lhs.chf == rhs.chf && lhs.aud == rhs.aud
            && lhs.jpy == rhs.jpy
    }
}

struct ExchangeRates: Codable {
    let uSDEUR: Double?
    let uSDGBP: Double?
    let uSDCAD: Double?
    let uSDCHF: Double?
    let uSDAUD: Double?
    let uSDJPY: Double?

    enum CodingKeys: String, CodingKey {
        case uSDEUR = "USDEUR"
        case uSDGBP = "USDGBP"
        case uSDCAD = "USDCAD"
        case uSDCHF = "USDCHF"
        case uSDAUD = "USDAUD"
        case uSDJPY = "USDJPY"
    }
}
