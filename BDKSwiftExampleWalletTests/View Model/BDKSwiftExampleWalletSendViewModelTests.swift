//
//  BDKSwiftExampleWalletSendViewModelTests.swift
//  BDKSwiftExampleWalletTests
//
//  Created by Matthew Ramsden on 8/24/23.
//

import BitcoinDevKit
import XCTest

@testable import BDKSwiftExampleWallet

final class BDKSwiftExampleWalletSendViewModelTests: XCTestCase {
    private enum TestSendError: Error {
        case failed
    }

    private func makeBDKClient(
        send: @escaping (String, UInt64, UInt64) async throws -> Void
    ) -> BDKClient {
        BDKClient(
            loadWallet: BDKClient.mock.loadWallet,
            deleteWallet: BDKClient.mock.deleteWallet,
            createWalletFromSeed: BDKClient.mock.createWalletFromSeed,
            createWalletFromDescriptor: BDKClient.mock.createWalletFromDescriptor,
            createWalletFromXPub: BDKClient.mock.createWalletFromXPub,
            getBalance: BDKClient.mock.getBalance,
            transactions: BDKClient.mock.transactions,
            listUnspent: BDKClient.mock.listUnspent,
            syncWithInspector: BDKClient.mock.syncWithInspector,
            fullScanWithInspector: BDKClient.mock.fullScanWithInspector,
            getAddress: BDKClient.mock.getAddress,
            send: send,
            sweepWif: BDKClient.mock.sweepWif,
            calculateFee: BDKClient.mock.calculateFee,
            calculateFeeRate: BDKClient.mock.calculateFeeRate,
            sentAndReceived: BDKClient.mock.sentAndReceived,
            txDetails: BDKClient.mock.txDetails,
            buildTransaction: BDKClient.mock.buildTransaction,
            getBackupInfo: BDKClient.mock.getBackupInfo,
            needsFullScan: BDKClient.mock.needsFullScan,
            setNeedsFullScan: BDKClient.mock.setNeedsFullScan,
            getNetwork: BDKClient.mock.getNetwork,
            getEsploraURL: BDKClient.mock.getEsploraURL,
            updateNetwork: BDKClient.mock.updateNetwork,
            updateEsploraURL: BDKClient.mock.updateEsploraURL,
            getAddressType: BDKClient.mock.getAddressType,
            updateAddressType: BDKClient.mock.updateAddressType,
            getClientType: BDKClient.mock.getClientType,
            updateClientType: BDKClient.mock.updateClientType
        )
    }

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
            try? viewModel.psbt?.extractTx().transactionID,
            "cab34ffffbde93c6a91d1ae755f6e256bad7c7e480a8c7d64caf3c2afc848ca4"
        )
    }

    @MainActor
    func testBuildTransactionViewModelSendPostsTransactionSentNotification() async {
        let viewModel = BuildTransactionViewModel(
            bdkClient: makeBDKClient(send: { _, _, _ in })
        )
        let expectation = XCTNSNotificationExpectation(name: .transactionSent)

        await viewModel.send(
            address: "tb1pxg0lakl0x4jee73f38m334qsma7mn2yv764x9an5ylht6tx8ccdsxtktrt",
            amount: 100_000,
            feeRate: 17
        )

        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertNil(viewModel.buildTransactionViewError)
        XCTAssertFalse(viewModel.showingBuildTransactionViewErrorAlert)
    }

    @MainActor
    func testBuildTransactionViewModelSendSurfacesAsyncFailure() async {
        let viewModel = BuildTransactionViewModel(
            bdkClient: makeBDKClient(send: { _, _, _ in
                throw TestSendError.failed
            })
        )

        await viewModel.send(
            address: "tb1pxg0lakl0x4jee73f38m334qsma7mn2yv764x9an5ylht6tx8ccdsxtktrt",
            amount: 100_000,
            feeRate: 17
        )

        XCTAssertNotNil(viewModel.buildTransactionViewError)
        XCTAssertTrue(viewModel.showingBuildTransactionViewErrorAlert)
    }

}
