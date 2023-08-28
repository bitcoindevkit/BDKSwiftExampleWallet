//
//  BDKSwiftExampleWalletSendViewModelTests.swift
//  BDKSwiftExampleWalletTests
//
//  Created by Matthew Ramsden on 8/24/23.
//

import XCTest
@testable import BDKSwiftExampleWallet

@MainActor
final class BDKSwiftExampleWalletSendViewModelTests: XCTestCase {
    
    func testReceiveViewModel() async {
        // Set up viewModel
        let viewModel = SendViewModel(feeClient: .mock, bdkClient: .mock)

        // Simulate successful getBalance() call
        viewModel.getBalance()
        XCTAssertGreaterThan(viewModel.balanceTotal!, UInt64(0))
        
        // Simulate successful getFees() call
        await viewModel.getFees()
        XCTAssertEqual(viewModel.recommendedFees?.fastestFee, 10)
    }
    
}
