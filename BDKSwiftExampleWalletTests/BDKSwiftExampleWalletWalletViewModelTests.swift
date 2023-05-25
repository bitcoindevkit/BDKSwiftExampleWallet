//
//  BDKSwiftExampleWalletWalletViewModelTests.swift
//  BDKSwiftExampleWalletTests
//
//  Created by Matthew Ramsden on 5/23/23.
//

import XCTest
@testable import BDKSwiftExampleWallet

final class BDKSwiftExampleWalletWalletViewModelTests: XCTestCase {
    
    // Segwit: bc1p...
    private func validateSegwitAddress(_ address: String) -> Bool {
        let segwitAddressRegex = "^tb1q[0-9a-zA-Z]{8,87}$"
        let addressPredicate = NSPredicate(format: "SELF MATCHES %@", segwitAddressRegex)
        return addressPredicate.evaluate(with: address)
    }
    
    // Taproot: bc1q...
    private func validateTaprootAddress(_ address: String) -> Bool {
        let taprootAddressRegex = "^tb1p[0-9a-zA-Z]{8,87}$"
        let addressPredicate = NSPredicate(format: "SELF MATCHES %@", taprootAddressRegex)
        return addressPredicate.evaluate(with: address)
    }
    
    func testWalletViewModel() async {
        
        // Set up viewModel
        let viewModel = WalletViewModel()
        XCTAssertEqual(viewModel.walletSyncState, .notStarted)
        XCTAssertEqual(viewModel.address, "")
        
        // Simulate successful getAddress() call
        viewModel.getAddress()
        XCTAssertEqual(viewModel.walletSyncState, .notStarted)
        XCTAssertEqual(viewModel.address, "tb1qzqkzcgqshhx753vay388tqmdnk6yrpfz9ue8cn")
        
        // Simulate successful sync() call
//        await viewModel.sync()
//        try? await Task.sleep(nanoseconds: 10_000_000_000)  // Wait for for the state to be updated
//        let walletSyncState = viewModel.walletSyncState
//        XCTAssertEqual(walletSyncState, .synced)
//        XCTAssertEqual(viewModel.address, "tb1qzqkzcgqshhx753vay388tqmdnk6yrpfz9ue8cn")
        
        // Additional validation
        XCTAssertTrue(validateSegwitAddress(viewModel.address), "Invalid Segwit address")
        XCTAssertFalse(validateTaprootAddress(viewModel.address), "Invalid Segwit address: Taproot address")
        XCTAssertFalse(viewModel.address.isEmpty, "Address should not be empty")
    }
    
}
