//
//  BDKSwiftExampleWalletTests.swift
//  BDKSwiftExampleWalletTests
//
//  Created by Matthew Ramsden on 5/22/23.
//

import XCTest

@testable import BDKSwiftExampleWallet

final class BDKSwiftExampleWalletTests: XCTestCase {

    func testExtractWifDetectsPrefixedWifAndRejectsRandomString() {
        let likelyWif = "c" + String(repeating: "1", count: 51)

        XCTAssertEqual(WifParser.extract(from: "wif:\(likelyWif)"), likelyWif)
        XCTAssertEqual(
            WifParser.extract(from: "bitcoin:?wif=\(likelyWif)"),
            likelyWif
        )
        XCTAssertNil(
            WifParser.extract(
                from: "12cUi8cuUJRiFmGEu4jCAsonSS1dkVyaD7Aoo6URRiXpmaokikuyM778786"
            )
        )
    }
}
