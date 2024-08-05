//
//  BDKSwiftExampleWalletSendViewModelTests.swift
//  BDKSwiftExampleWalletTests
//
//  Created by Matthew Ramsden on 8/24/23.
//

import XCTest

@testable import BDKSwiftExampleWallet

final class BDKSwiftExampleWalletSendViewModelTests: XCTestCase {

    @MainActor
    func testAmountViewModel() async {
        // Set up viewModel
        let viewModel = AmountViewModel(bdkClient: .mock)

        // Simulate successful getBalance() call
        viewModel.getBalance()
        XCTAssertGreaterThan(viewModel.balanceTotal!, UInt64(0))
    }

    @MainActor
    func testFeeViewModel() async {
        // Set up viewModel
        let viewModel = FeeViewModel(feeClient: .mock, bdkClient: .mock)

        // Simulate successful getFees() call
        await viewModel.getFees()
        XCTAssertEqual(viewModel.recommendedFees?.fastestFee, 10)
    }

    @MainActor
    func testBuildTransactionViewModel() async {
        // Set up viewModel
        let viewModel = BuildTransactionViewModel(bdkClient: .mock)

        let amount = "100000"
        let address = "tb1pxg0lakl0x4jee73f38m334qsma7mn2yv764x9an5ylht6tx8ccdsxtktrt"
        let fee = UInt64(17)

        // Simulate successful buildTransaction() call
        viewModel.buildTransaction(
            address: address,
            amount: UInt64(Int64(amount) ?? 0),
            feeRate: fee
        )
        XCTAssertEqual(
            try? viewModel.psbt?.extractTx().computeTxid(),
            "cab34ffffbde93c6a91d1ae755f6e256bad7c7e480a8c7d64caf3c2afc848ca4"
        )
    }

}
