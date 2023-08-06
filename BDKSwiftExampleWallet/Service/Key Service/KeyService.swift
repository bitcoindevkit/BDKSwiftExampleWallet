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

    enum KeyDataError: Error {
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
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(backupInfo)
            keychain[data: "BackupInfo"] = data
        } catch {
            throw KeyDataError.encodingError
        }
     }

    func getBackupInfo() throws -> BackupInfo {
        do {
            guard let encryptedJsonData = try keychain.getData("BackupInfo") else {
                throw KeyDataError.readError
            }
            let decoder = JSONDecoder()
            let backupInfo = try decoder.decode(BackupInfo.self, from: encryptedJsonData)
            return backupInfo
        } catch {
            throw KeyDataError.decodingError
        }
    }
        
    private func deleteBackupInfo() throws {
        do {
            try keychain.remove("BackupInfo")
        } catch let error {
            throw error
        }
    }

}
