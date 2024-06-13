//
//  BDKSwiftExampleWalletKeyServiceTests.swift
//  BDKSwiftExampleWalletTests
//
//  Created by Matthew Ramsden on 8/27/23.
//

import BitcoinDevKit
import XCTest

@testable import BDKSwiftExampleWallet

final class BDKSwiftExampleWalletKeyServiceTests: XCTestCase {

    func testKeyClientMockBackupInfo() throws {
        let backupInfo = try KeyClient.mock.getBackupInfo()

        let words12 =
            "space echo position wrist orient erupt relief museum myself grain wisdom tumble"
        let mnemonic = try Mnemonic.fromString(mnemonic: words12)
        let secretKey = DescriptorSecretKey(
            network: mockKeyClientNetwork,
            mnemonic: mnemonic,
            password: nil
        )
        let descriptor = Descriptor.newBip86(
            secretKey: secretKey,
            keychain: .external,
            network: mockKeyClientNetwork
        )
        let changeDescriptor = Descriptor.newBip86(
            secretKey: secretKey,
            keychain: .internal,
            network: mockKeyClientNetwork
        )
        let backupInfoMock = BackupInfo(
            mnemonic: mnemonic.description,
            descriptor: descriptor.description,
            changeDescriptor: changeDescriptor.toStringWithSecret()
        )

        XCTAssertEqual(backupInfo, backupInfoMock)
    }

}
