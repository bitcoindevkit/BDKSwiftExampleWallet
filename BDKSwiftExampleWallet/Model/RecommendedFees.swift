//
//  RecommendedFees.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/23/23.
//

import Foundation

struct RecommendedFees: Codable, Equatable {
    let fastestFee: Int
    let halfHourFee: Int
    let hourFee: Int
    let economyFee: Int
    let minimumFee: Int
}

#if DEBUG
    let currentFeesMock = RecommendedFees(
        fastestFee: 10,
        halfHourFee: 8,
        hourFee: 6,
        economyFee: 4,
        minimumFee: 2
    )
#endif
