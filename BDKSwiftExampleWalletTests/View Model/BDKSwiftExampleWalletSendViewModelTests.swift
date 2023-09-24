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
    
    func testAmountViewModel() async {
        // Set up viewModel
        let viewModel = AmountViewModel(bdkClient: .mock)
        
        // Simulate successful getBalance() call
        viewModel.getBalance()
        XCTAssertGreaterThan(viewModel.balanceTotal!, UInt64(0))
    }
    
    func testFeeViewModel() async {
        // Set up viewModel
        let viewModel = FeeViewModel(feeClient: .mock, bdkClient: .mock)
        
        // Simulate successful getFees() call
        await viewModel.getFees()
        XCTAssertEqual(viewModel.recommendedFees?.fastestFee, 10)
    }
    
    func testBuildTransactionViewModel() async {
        // Set up viewModel
        let viewModel = BuildTransactionViewModel(bdkClient: .mock)
        
        let amount = "100000"
        let address = "tb1pxg0lakl0x4jee73f38m334qsma7mn2yv764x9an5ylht6tx8ccdsxtktrt"
        let fee: Float = 17.0
        
        // Simulate successful buildTransaction() call
        viewModel.buildTransaction(address: address, amount: UInt64(Int64(amount) ?? 0), feeRate: fee)
        XCTAssertEqual(viewModel.txBuilderResult?.transactionDetails.fee, 2820)
    }
    
}
