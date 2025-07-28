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
    
    func testBDKClientGetClientType() {
        let clientType = BDKClient.mock.getClientType()
        
        XCTAssertEqual(clientType, .esplora)
    }
    
    func testBDKClientUpdateClientType() {
        // This test verifies that updateClientType doesn't crash with mock client
        // In the real implementation, setting an unimplemented type would fallback to esplora
        BDKClient.mock.updateClientType(.kyoto)
        
        // Verify it still returns esplora (since mock doesn't actually change)
        let clientType = BDKClient.mock.getClientType()
        XCTAssertEqual(clientType, .esplora)
    }
    
    func testBlockchainClientTypeEnumValues() {
        // Test that all expected client types are available
        let allCases = BlockchainClientType.allCases
        XCTAssertTrue(allCases.contains(.esplora))
        XCTAssertTrue(allCases.contains(.kyoto))
        XCTAssertTrue(allCases.contains(.electrum))
        XCTAssertEqual(allCases.count, 3)
    }
    
    func testBlockchainClientEsploraFactory() {
        // Test that the esplora factory method works correctly
        let testURL = "https://blockstream.info/testnet/api"
        let client = BlockchainClient.esplora(url: testURL)
        
        XCTAssertEqual(client.getUrl(), testURL)
        XCTAssertEqual(client.getType(), .esplora)
        XCTAssertTrue(client.supportsFullScan())
    }

}
