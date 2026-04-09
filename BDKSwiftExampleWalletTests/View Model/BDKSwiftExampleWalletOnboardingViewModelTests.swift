//
//  BDKSwiftExampleWalletOnboardingViewModelTests.swift
//  BDKSwiftExampleWalletTests
//
//  Created by Codex on 4/9/26.
//

import Foundation
import XCTest

@testable import BDKSwiftExampleWallet

final class BDKSwiftExampleWalletOnboardingViewModelTests: XCTestCase {
    private enum TestOnboardingError: Error {
        case noBackup
    }

    private func makeBDKClient(
        createWalletFromSeed: @escaping (String?) throws -> Void,
        getBackupInfo: @escaping () throws -> BackupInfo = { throw TestOnboardingError.noBackup }
    ) -> BDKClient {
        BDKClient(
            loadWallet: BDKClient.mock.loadWallet,
            deleteWallet: BDKClient.mock.deleteWallet,
            createWalletFromSeed: createWalletFromSeed,
            createWalletFromDescriptor: BDKClient.mock.createWalletFromDescriptor,
            createWalletFromXPub: BDKClient.mock.createWalletFromXPub,
            getBalance: BDKClient.mock.getBalance,
            transactions: BDKClient.mock.transactions,
            listUnspent: BDKClient.mock.listUnspent,
            syncWithInspector: BDKClient.mock.syncWithInspector,
            fullScanWithInspector: BDKClient.mock.fullScanWithInspector,
            getAddress: BDKClient.mock.getAddress,
            send: BDKClient.mock.send,
            sweepWif: BDKClient.mock.sweepWif,
            calculateFee: BDKClient.mock.calculateFee,
            calculateFeeRate: BDKClient.mock.calculateFeeRate,
            sentAndReceived: BDKClient.mock.sentAndReceived,
            txDetails: BDKClient.mock.txDetails,
            buildTransaction: BDKClient.mock.buildTransaction,
            getBackupInfo: getBackupInfo,
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
    func testCreateWalletIgnoresRepeatedCallsWhileCreationInProgress() async {
        let started = expectation(description: "wallet creation started")
        let created = XCTNSNotificationExpectation(name: .walletCreated)
        let unblockCreation = DispatchSemaphore(value: 0)
        var createCallCount = 0

        let viewModel = OnboardingViewModel(
            bdkClient: makeBDKClient(createWalletFromSeed: { _ in
                createCallCount += 1
                started.fulfill()
                unblockCreation.wait()
            })
        )
        viewModel.words =
            "abandon ability able about above absent absorb abstract absurd abuse access accident"

        viewModel.createWallet()
        await fulfillment(of: [started], timeout: 1.0)
        viewModel.createWallet()

        XCTAssertTrue(viewModel.isCreatingWallet)
        XCTAssertEqual(createCallCount, 1)

        unblockCreation.signal()
        await fulfillment(of: [created], timeout: 1.0)
        XCTAssertFalse(viewModel.isCreatingWallet)
    }
}
