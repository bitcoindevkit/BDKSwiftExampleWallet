//
//  BDKSwiftExampleWalletFeeServiceTests.swift
//  BDKSwiftExampleWalletTests
//
//  Created by Matthew Ramsden on 8/27/23.
//

import XCTest
@testable import BDKSwiftExampleWallet

final class BDKSwiftExampleWalletFeeServiceTests: XCTestCase {

    // MARK: API

    /// Test Price API Service mock
    func testAPIServiceMock() async throws {
        let currentFees = try await FeeClient.mock.fetchFees()

        XCTAssertEqual(currentFees, currentFeesMock)
    }

}
