//
//  BDKSwiftExampleWalletDate+Extensions.swift
//  BDKSwiftExampleWalletTests
//
//  Created by Matthew Ramsden on 8/24/23.
//

import XCTest
@testable import BDKSwiftExampleWallet

final class BDKSwiftExampleWalletDate_Extensions: XCTestCase {

    func testFormattedSyncTime() {
        let date = Date(timeIntervalSince1970: 1674596400)
        let formattedTime = date.formattedSyncTime()
        
        XCTAssertEqual(formattedTime, "1/24/23, 3:40 PM")
    }

}
