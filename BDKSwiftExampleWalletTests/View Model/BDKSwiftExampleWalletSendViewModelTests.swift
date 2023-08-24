//
//  BDKSwiftExampleWalletSendViewModelTests.swift
//  BDKSwiftExampleWalletTests
//
//  Created by Matthew Ramsden on 8/24/23.
//

import XCTest
@testable import BDKSwiftExampleWallet

final class BDKSwiftExampleWalletSendViewModelTests: XCTestCase {
    
    func testReceiveViewModel() async {
        // Set up viewModel
        let viewModel = await SendViewModel(feeService: .init())

        // Simulate successful getBalance() call
        await viewModel.getBalance()
        let total = await viewModel.balanceTotal
        XCTAssertGreaterThan(total, 0)
        
        // Simulate successful getFees() call
        await viewModel.getFees()
        if let fees = await viewModel.recommendedFees {
            XCTAssertGreaterThan(fees.fastestFee, 0)
        }
        
    }
    
}
