//
//  BDKSwiftExampleWalletPriceServiceTests.swift
//  BDKSwiftExampleWalletTests
//
//  Created by Matthew Ramsden on 8/26/23.
//

import XCTest
@testable import BDKSwiftExampleWallet

final class BDKSwiftExampleWalletPriceServiceTests: XCTestCase {
    let currentPriceMock = Price(time: 1693079705, usd: 26030, eur: 24508, gbp: 22486, cad: 35314, chf: 23088, aud: 40657, jpy: 3816606)

    // MARK: Model
    
    /// Test if mock response is not nil
    func testCurrentPriceNotNil() {
        let currentPrice = currentPriceMock
        XCTAssertNotNil(currentPrice)
    }
    
    // MARK: API

    /// Test Price API Service mock
    func testAPIServiceMock() async throws {
        let currentPrice = try await PriceClient.mock.fetchPrice()

        XCTAssertEqual(currentPrice, currentPriceMock)
    }

    
    // MARK: View Model

//    /// Test if view model mock response is not nil
//    func testViewModelNotNil() {
//        let viewModel = PriceViewModel(apiService: .mock)
//
//        XCTAssertNil(viewModel.price)
//    }
//
//    /// Test view model mock response for current price item
//    func testViewModelLoadPrice() async {
//        let viewModel = PriceViewModel(apiService: .mock)
//
//        await viewModel.fetchPrice()
//
//        guard let currentPriceItem = viewModel.price else {
//            XCTFail("Expected non-nil current price")
//            return
//        }
//
//        let mockCurrentPriceItem = CurrentPriceItem(id: 3406925, mid: 27960.35)
//
//        XCTAssertEqual(currentPriceItem, mockCurrentPriceItem)
//    }

}
