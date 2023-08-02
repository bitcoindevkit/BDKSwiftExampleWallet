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
//        await viewModel.sync()
//        try? await Task.sleep(nanoseconds: 10_000_000_000)  // Wait for for the state to be updated
//        let walletSyncState = viewModel.walletSyncState
//        XCTAssertEqual(walletSyncState, .synced)
//        XCTAssertEqual(viewModel.address, "tb1qzqkzcgqshhx753vay388tqmdnk6yrpfz9ue8cn")
        
        // Simulate successful getBalance() call
        viewModel.getBalance()
        XCTAssertEqual(viewModel.walletSyncState, .notStarted)
        XCTAssertEqual(viewModel.balanceTotal, 0)
        
        // Simulate successful getTransactions() call
        viewModel.getTransactions()
        XCTAssertEqual(viewModel.walletSyncState, .notStarted)
        XCTAssertEqual(viewModel.transactionDetails.count, 0)

    }
    
}
