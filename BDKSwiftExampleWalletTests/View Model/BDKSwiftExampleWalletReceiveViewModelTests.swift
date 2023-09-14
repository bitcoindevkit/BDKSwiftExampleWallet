//
//  BDKSwiftExampleWalletReceiveTests.swift
//  BDKSwiftExampleWalletTests
//
//  Created by Matthew Ramsden on 6/20/23.
//

import XCTest

@testable import BDKSwiftExampleWallet

final class BDKSwiftExampleWalletReceiveViewModelTests: XCTestCase {

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

    func testReceiveViewModel() {
        // Set up viewModel
        let viewModel = ReceiveViewModel(bdkClient: .mock)
        XCTAssertEqual(viewModel.address, "")

        // Simulate successful getAddress() call
        viewModel.getAddress()
        XCTAssertEqual(viewModel.address, "tb1pd8jmenqpe7rz2mavfdx7uc8pj7vskxv4rl6avxlqsw2u8u7d4gfs97durt")

        // Additional validation
        XCTAssertFalse(validateSegwitAddress(viewModel.address), "Invalid Segwit address")
        print(viewModel.address)
        XCTAssertTrue(
            validateTaprootAddress(viewModel.address),
            "Invalid Segwit address: Taproot address"
        )
        XCTAssertEqual(viewModel.address, "tb1pd8jmenqpe7rz2mavfdx7uc8pj7vskxv4rl6avxlqsw2u8u7d4gfs97durt")
        XCTAssertFalse(viewModel.address.isEmpty, "Address should not be empty")
    }

}
