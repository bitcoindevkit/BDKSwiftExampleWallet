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

        XCTAssertEqual(address, "mockAddress")
    }

    func testBDKClientMockGetBalance() throws {
        let balance = try BDKClient.mock.getBalance()

        XCTAssertEqual(balance, mockBalance)
    }

    func testBDKClientMockGetTransactions() throws {
        let transactionDetails = try BDKClient.mock.getTransactions()

        XCTAssertEqual(transactionDetails.first?.txid, mockTransactionDetails.first?.txid)
    }

}
