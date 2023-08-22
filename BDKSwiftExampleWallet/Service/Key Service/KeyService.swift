//
//  KeyService.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/4/23.
//

import Foundation
import KeychainAccess

struct KeyService {
    private let keychain: Keychain
    
    init() {
        let keychain = Keychain(service: "com.matthewramsden.bdkswiftexamplewallet.testservice") // TODO: use `Bundle.main.displayName` or something like com.bdk.swiftwalletexample
            .label(Bundle.main.displayName)
            .synchronizable(true)
            .accessibility(.whenUnlocked)
        self.keychain = keychain
    }

    enum BackupInfoError: Error {
        case encodingError
        case writeError
        case urlError
        case decodingError
        case readError
    }
}

extension KeyService {
    
    func saveBackupInfo(backupInfo: BackupInfo) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(backupInfo)
        keychain[data: "BackupInfo"] = data
     }

    func getBackupInfo() throws -> BackupInfo {
        guard let encryptedJsonData = try keychain.getData("BackupInfo") else { throw BackupInfoError.readError }
        let decoder = JSONDecoder()
        let backupInfo = try decoder.decode(BackupInfo.self, from: encryptedJsonData)
        return backupInfo
    }
        
    func deleteBackupInfo() throws {
        try keychain.remove("BackupInfo")
    }

}
