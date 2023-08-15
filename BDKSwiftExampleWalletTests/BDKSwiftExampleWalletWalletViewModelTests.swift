//
//  BDKSwiftExampleWalletWalletViewModelTests.swift
//  BDKSwiftExampleWalletTests
//
//  Created by Matthew Ramsden on 5/23/23.
//

import XCTest
@testable import BDKSwiftExampleWallet

final class BDKSwiftExampleWalletWalletViewModelTests: XCTestCase {
    
    func testWalletViewModel() async {
        
        // Set up viewModel
        let viewModel = WalletViewModel(priceService: .init())
        XCTAssertEqual(viewModel.walletSyncState, .notStarted)
        
        // Simulate successful sync() call
        await viewModel.sync()
        try? await Task.sleep(nanoseconds: 10_000_000_000)  // Wait 10sec for the state to be updated
        let walletSyncState = viewModel.walletSyncState
        XCTAssertEqual(walletSyncState, .synced)

        // Simulate successful getBalance() call
        viewModel.getBalance()
        XCTAssertEqual(viewModel.walletSyncState, .synced)
        XCTAssertEqual(viewModel.balanceTotal, 21318468)
        
        // Simulate successful getTransactions() call
        viewModel.getTransactions()
        XCTAssertEqual(viewModel.walletSyncState, .synced)
        XCTAssertEqual(viewModel.transactionDetails.count, 10)
        
        // Simulate successful getPrices() call
        await viewModel.getPrices()
        try? await Task.sleep(nanoseconds: 10_000_000_000)  // Wait 10sec for the state to be updated
        XCTAssertEqual(viewModel.walletSyncState, .synced)
        XCTAssertEqual(viewModel.price, 29412.0)

    }
    
}
