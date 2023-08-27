//
//  KeyService.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/4/23.
//

import Foundation
import KeychainAccess
import BitcoinDevKit

private struct KeyService {
    private let keychain: Keychain

    init() {
        let keychain = Keychain(service: "com.matthewramsden.bdkswiftexamplewallet.testservice") // TODO: use `Bundle.main.displayName` or something like com.bdk.swiftwalletexample
            .label(Bundle.main.displayName)
            .synchronizable(true)
            .accessibility(.whenUnlocked)
        self.keychain = keychain
    }
    
    func saveBackupInfo(backupInfo: BackupInfo) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(backupInfo)
        keychain[data: "BackupInfo"] = data
     }

    func getBackupInfo() throws -> BackupInfo {
        guard let encryptedJsonData = try keychain.getData("BackupInfo") else { throw KeyServiceError.readError }
        let decoder = JSONDecoder()
        let backupInfo = try decoder.decode(BackupInfo.self, from: encryptedJsonData)
        return backupInfo
    }
        
    func deleteBackupInfo() throws {
        try keychain.remove("BackupInfo")
    }
}

struct KeyAPIService {
    let saveBackupInfo: (BackupInfo) throws -> ()
    let getBackupInfo: () throws -> BackupInfo
    let deleteBackupInfo: () throws -> ()

    private init(saveBackupInfo: @escaping (BackupInfo) throws -> (), getBackupInfo: @escaping () throws -> BackupInfo, deleteBackupInfo: @escaping () throws -> ()) {
        self.saveBackupInfo = saveBackupInfo
        self.getBackupInfo = getBackupInfo
        self.deleteBackupInfo = deleteBackupInfo
    }
}

extension KeyAPIService {
    static let live = Self(
        saveBackupInfo: { backupInfo in try KeyService().saveBackupInfo(backupInfo: backupInfo) },
        getBackupInfo: { try KeyService().getBackupInfo() },
        deleteBackupInfo: { try KeyService().deleteBackupInfo() }
    )
}

#if DEBUG
private let network = Network.regtest
extension KeyAPIService {
    static let mock = Self(
        saveBackupInfo: { _ in },
        getBackupInfo: {
            let mnemonicWords12 = "space echo position wrist orient erupt relief museum myself grain wisdom tumble"
            let mnemonic = try Mnemonic.fromString(mnemonic: mnemonicWords12)
            let secretKey = DescriptorSecretKey(
                network: network,
                mnemonic: mnemonic,
                password: nil
            )
            let descriptor = Descriptor.newBip84(
                secretKey: secretKey,
                keychain: .external,
                network: network
            )
            let changeDescriptor = Descriptor.newBip84(
                secretKey: secretKey,
                keychain: .internal,
                network: network
            )
            let backupInfo = BackupInfo(
                mnemonic: mnemonic.asString(),
                descriptor: descriptor.asString(),
                changeDescriptor: changeDescriptor.asStringPrivate()
            )
            return backupInfo
        },
        deleteBackupInfo: { try KeyService().deleteBackupInfo() }
    )
}
#endif
