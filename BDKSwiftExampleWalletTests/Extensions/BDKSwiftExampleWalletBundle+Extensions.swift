//
//  BDKSwiftExampleWalletBundle+Extensions.swift
//  BDKSwiftExampleWalletTests
//
//  Created by Matthew Ramsden on 8/22/23.
//

import XCTest

@testable import BDKSwiftExampleWallet

final class BDKSwiftExampleWalletBundle_Extensions: XCTestCase {

    func testDisplayName() {
        let displayName = Bundle.main.displayName

        // Check that the displayName is not empty
        XCTAssertFalse(displayName.isEmpty)

        // Check that the displayName is either the bundle name or the bundle identifier
        if let bundleName = Bundle.main.infoDictionary?["CFBundleName"] as? String {
            XCTAssertEqual(displayName, bundleName)
        } else if let bundleIdentifier = Bundle.main.bundleIdentifier {
            XCTAssertEqual(displayName, bundleIdentifier)
        } else {
            XCTAssertEqual(displayName, "Unknown Bundle")
        }
    }

}
