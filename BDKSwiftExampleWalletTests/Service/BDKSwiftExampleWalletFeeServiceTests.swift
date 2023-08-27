//
//  BDKSwiftExampleWalletFeeServiceTests.swift
//  BDKSwiftExampleWalletTests
//
//  Created by Matthew Ramsden on 8/27/23.
//

import XCTest
@testable import BDKSwiftExampleWallet

final class BDKSwiftExampleWalletFeeServiceTests: XCTestCase {

    func testFeeClientMock() async throws {
        let currentFees = try await FeeClient.mock.fetchFees()

        XCTAssertEqual(currentFees, currentFeesMock)
    }

}
