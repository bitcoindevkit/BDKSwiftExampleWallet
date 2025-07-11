//
//  BDKSwiftExampleWalletInt+Extensions.swift
//  BDKSwiftExampleWalletTests
//
//  Created by Matthew Ramsden on 7/8/23.
//

import XCTest

@testable import BDKSwiftExampleWallet

final class BDKSwiftExampleWalletInt_Extensions: XCTestCase {

    func testFormatterSatoshis() {
        let oneHundred = UInt64(100).formattedSatoshis()
        XCTAssertEqual(oneHundred, "0.00 000 100")

        let oneThousandOne = UInt64(1001).formattedSatoshis()
        XCTAssertEqual(oneThousandOne, "0.00 001 001")

        let oneHundredThousandOne = UInt64(100001).formattedSatoshis()
        XCTAssertEqual(oneHundredThousandOne, "0.00 100 001")

        let oneMillionOne = UInt64(1_000_001).formattedSatoshis()
        XCTAssertEqual(oneMillionOne, "0.01 000 001")

        let oneHundredMillionOne = UInt64(100_000_001).formattedSatoshis()
        XCTAssertEqual(oneHundredMillionOne, "1.00 000 001")

        let tenBTC = UInt64(1_000_000_001).formattedSatoshis()
        XCTAssertEqual(tenBTC, "10.00 000 001")
    }

    func testBip177() {
        let oneHundred = UInt64(100).formattedBip177()
        print(oneHundred)
        XCTAssertEqual(oneHundred, "100")
        
        let oneThousand = UInt64(1000).formattedBip177()
        print(oneThousand)
        XCTAssertEqual(oneThousand, "1K")
        
        let oneThousandOne = UInt64(1001).formattedBip177()
        print(oneThousandOne)
        XCTAssertEqual(oneThousandOne, "1,001")
        
        let tenThousand = UInt64(10000).formattedBip177()
        print(tenThousand)
        XCTAssertEqual(tenThousand, "10K")
        
        let tenThousandOne = UInt64(10001).formattedBip177()
        print(tenThousandOne)
        XCTAssertEqual(tenThousandOne, "10,001")
        
        let oneHundredThousand = UInt64(100000).formattedBip177()
        print(oneHundredThousand)
        XCTAssertEqual(oneHundredThousand, "100K")
        
        let oneHundredThousandOne = UInt64(100001).formattedBip177()
        print(oneHundredThousandOne)
        XCTAssertEqual(oneHundredThousandOne, "100,001")
        
        let oneMillion = UInt64(1000000).formattedBip177()
        print(oneMillion)
        XCTAssertEqual(oneMillion, "1M")
        
        let oneMillionOne = UInt64(1000001).formattedBip177()
        print(oneMillionOne)
        XCTAssertEqual(oneMillionOne, "1,000,001")
        
        let treeMillions = UInt64(325_000_000).formattedBip177()
        print(treeMillions)
        XCTAssertEqual(treeMillions, "325M")
        
        let treeMillionsOne = UInt64(325_000_001).formattedBip177()
        print(treeMillionsOne)
        XCTAssertEqual(treeMillionsOne, "325,000,001")
    }
}
