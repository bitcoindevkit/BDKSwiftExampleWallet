//
//  KeyService.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/4/23.
//

import Foundation
import KeychainAccess

struct KeyService {
    private let keychain = Keychain(service: "com.matthewramsden.bdkswiftexamplewallet.testservice")

    enum BackupInfoError: Error {
        case encodingError
        case writeError
        case urlError
        case decodingError
        case readError
    }
}

extension KeyService {
    
    // look at ways to encode + encrypt
    func saveBackupInfo(backupInfo: BackupInfo) throws {
//        do {
//            let encoder = JSONEncoder()
//            let data = try encoder.encode(backupInfo)
//            keychain[data: "BackupInfo"] = data
//        } catch {
//            throw BackupInfoError.encodingError
//        }
        let encoder = JSONEncoder()
        let data = try encoder.encode(backupInfo)
        keychain[data: "BackupInfo"] = data
     }

    // look at ways to decode + decrypt
    func getBackupInfo() throws -> BackupInfo {
//        do {
//            guard let encryptedJsonData = try keychain.getData("BackupInfo") else {
//                throw BackupInfoError.readError
//            }
//            let decoder = JSONDecoder()
//            let backupInfo = try decoder.decode(BackupInfo.self, from: encryptedJsonData)
//            return backupInfo
//        } catch {
//            throw BackupInfoError.decodingError
//        }
        guard let encryptedJsonData = try keychain.getData("BackupInfo") else {
            throw BackupInfoError.readError
        }
        let decoder = JSONDecoder()
        let backupInfo = try decoder.decode(BackupInfo.self, from: encryptedJsonData)
        return backupInfo
    }
        
    private func deleteBackupInfo() throws {
//        do {
//            try keychain.remove("BackupInfo")
//        } catch let error {
//            throw error
//        }
        try keychain.remove("BackupInfo")
    }

}
