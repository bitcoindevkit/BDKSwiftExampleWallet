//
//  BDKSwiftExampleWalletDouble+Extensions.swift
//  BDKSwiftExampleWalletTests
//
//  Created by Matthew Ramsden on 8/24/23.
//

import XCTest
@testable import BDKSwiftExampleWallet

final class BDKSwiftExampleWalletDouble_Extensions: XCTestCase {

    func testFormattedPrice() {
        let price: Double = 1234.56
        let formattedPrice = price.formattedPrice(currencyCode: .EUR)
        
        XCTAssertEqual(formattedPrice, "€1,234.56")
    }
     
    func testValueInUSD() {
        let bitcoinAmount: Double = 0.005
        let currentBitcoinPrice: Double = 50000.0
        let usdValue = bitcoinAmount.valueInUSD(price: currentBitcoinPrice)
        
        XCTAssertEqual(usdValue, "$0.00")
    }

}
