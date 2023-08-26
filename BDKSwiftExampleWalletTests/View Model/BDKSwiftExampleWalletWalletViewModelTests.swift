//
//  BDKSwiftExampleWalletWalletViewModelTests.swift
//  BDKSwiftExampleWalletTests
//
//  Created by Matthew Ramsden on 5/23/23.
//

import XCTest
@testable import BDKSwiftExampleWallet

@MainActor
final class BDKSwiftExampleWalletWalletViewModelTests: XCTestCase {
    
    func testWalletViewModel() async {
        
        // Set up viewModel
        let viewModel = WalletViewModel(priceService: .mock, bdkService: .mock)
        //XCTAssertEqual(viewModel.walletSyncState, .notStarted)
        
        // Simulate successful sync() call
        await viewModel.sync()
        try? await Task.sleep(nanoseconds: 10_000_000_000)  // Wait for for the state to be updated
        //XCTAssertEqual(viewModel.walletSyncState, .synced)
        
        // Simulate successful getBalance() call
        viewModel.getBalance()
        ////XCTAssertGreaterThan(viewModel.balanceTotal, 0)
        
        // Simulate successful getTransactions() call
        viewModel.getTransactions()
        //XCTAssertGreaterThan(viewModel.transactionDetails.count, 1)
        
        // Simulate successful getPrices() call
        await viewModel.getPrices()
        try? await Task.sleep(nanoseconds: 10_000_000_000)  // Wait 10sec for the state to be updated
        //XCTAssertEqual(viewModel.satsPrice, "$0.00")
    }
    
}
