//
//  BDKSwiftExampleWalletTests.swift
//  BDKSwiftExampleWalletTests
//
//  Created by Matthew Ramsden on 5/22/23.
//

import SwiftUI
import XCTest

@testable import BDKSwiftExampleWallet

final class BDKSwiftExampleWalletTests: XCTestCase {

    func testExtractWifDetectsPrefixedWifAndRejectsRandomString() {
        let view = AddressView(navigationPath: .constant(NavigationPath()))
        let likelyWif = "c" + String(repeating: "1", count: 51)

        XCTAssertEqual(view.extractWif(from: "wif:\(likelyWif)"), likelyWif)
        XCTAssertNil(
            view.extractWif(
                from: "12cUi8cuUJRiFmGEu4jCAsonSS1dkVyaD7Aoo6URRiXpmaokikuyM778786"
            )
        )
    }
}
