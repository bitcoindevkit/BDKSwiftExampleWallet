//
//  BDKSwiftExampleWalletBDKServiceTests.swift
//  BDKSwiftExampleWalletTests
//
//  Created by Matthew Ramsden on 8/27/23.
//

import BitcoinDevKit
import XCTest

@testable import BDKSwiftExampleWallet

final class BDKSwiftExampleWalletBDKServiceTests: XCTestCase {

    func testBDKClientMockGetAddress() throws {
        let address = try BDKClient.mock.getAddress()

        XCTAssertEqual(address, "tb1pd8jmenqpe7rz2mavfdx7uc8pj7vskxv4rl6avxlqsw2u8u7d4gfs97durt")
    }

    func testBDKClientMockGetBalance() throws {
        let balance = try BDKClient.mock.getBalance()

        XCTAssertEqual(balance, .mock)
    }

    func testBDKClientMockGetTransactions() throws {
        let transactionDetails = try BDKClient.mock.transactions()

        XCTAssertEqual(
            transactionDetails.first?.transaction.transactionID,
            Transaction.mock?.transactionID
        )
    }

}
