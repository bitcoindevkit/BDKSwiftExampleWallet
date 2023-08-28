//
//  BDKSwiftExampleWalletPriceServiceTests.swift
//  BDKSwiftExampleWalletTests
//
//  Created by Matthew Ramsden on 8/26/23.
//

import XCTest

@testable import BDKSwiftExampleWallet

final class BDKSwiftExampleWalletPriceServiceTests: XCTestCase {

    func testAPIServiceMock() async throws {
        let currentPrice = try await PriceClient.mock.fetchPrice()

        XCTAssertEqual(currentPrice, currentPriceMock)
    }

    func testAPIServiceMockZero() async throws {
        let currentPrice = try await PriceClient.mockZero.fetchPrice()

        XCTAssertEqual(currentPrice, currentPriceMockZero)
    }

}
