//
//  BDKSwiftExampleWalletInt+Extensions.swift
//  BDKSwiftExampleWalletTests
//
//  Created by Matthew Ramsden on 7/8/23.
//

import XCTest

@testable import BDKSwiftExampleWallet

final class BDKSwiftExampleWalletInt_Extensions: XCTestCase {

    func testFormatterSatoshis() {
        let oneHundred = UInt64(100).formattedSatoshis()
        XCTAssertEqual(oneHundred, "0.00 000 100")

        let oneThousandOne = UInt64(1001).formattedSatoshis()
        XCTAssertEqual(oneThousandOne, "0.00 001 001")

        let oneHundredThousandOne = UInt64(100001).formattedSatoshis()
        XCTAssertEqual(oneHundredThousandOne, "0.00 100 001")

        let oneMillionOne = UInt64(1_000_001).formattedSatoshis()
        XCTAssertEqual(oneMillionOne, "0.01 000 001")

        let oneHundredMillionOne = UInt64(100_000_001).formattedSatoshis()
        XCTAssertEqual(oneHundredMillionOne, "1.00 000 001")

        let tenBTC = UInt64(1_000_000_001).formattedSatoshis()
        XCTAssertEqual(tenBTC, "10.00 000 001")
    }

}
