//
//  KeyService.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/4/23.
//

import Foundation
import KeychainAccess

// Make this a singleton?
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

// Save to Keychain
extension KeyService {
    
    // look at ways to encode + encrypt
    func saveBackupInfo(backupInfo: KeyData) throws {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(backupInfo)
            keychain[data: "BackupInfo"] = data
        } catch {
            // Handle the error, e.g., print or log it.
            print("Error encoding backupInfo: \(error)")
            throw KeyDataError.decodingError
        }
     }

    // look at ways to decode + decrypt
    func getBackupInfo() throws -> KeyData {
        do {
            guard let encryptedJsonData = try keychain.getData("BackupInfo") else {
                throw KeyDataError.decodingError
            }
            let decoder = JSONDecoder()
            let backupInfo = try decoder.decode(KeyData.self, from: encryptedJsonData)
            return backupInfo
        } catch {
            throw KeyDataError.decodingError
        }
    }
        
    // Delete backup info from keychain - WARNING!
    private func deleteBackupInfo() throws {
        do {
            try keychain.remove("BackupInfo")
        } catch let error {
            // Handle the error, e.g., print or log it.
            print("Error while deleting BackupInfo: \(error)")
            throw error
        }
    }

}


// Save to FileManager
extension KeyService {
    //    // Save KeyData as file
    //    func saveKeyData(keyData: KeyData) throws {
    //        let fileManager = FileManager.default
    //        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
    //        if let url = urls.first {
    //            let fileURL = url.appendingPathComponent("KeyData.json")
    //            if let jsonData = try? JSONEncoder().encode(keyData) {
    //                do {
    //                    try jsonData.write(to: fileURL, options: [.atomicWrite])
    //                    print("saveKeyData success")
    //                } catch {
    //                    throw KeyDataError.writeError
    //                }
    //            } else  {
    //                throw KeyDataError.encodingError
    //            }
    //        } else {
    //            throw KeyDataError.urlError
    //        }
    //    }
    //
    //    // Get KeyData from file
    //    func getKeyData() throws -> KeyData {
    //        let fileManager = FileManager.default
    //        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
    //        if let url = urls.first {
    //            let fileURL = url.appendingPathComponent("KeyData.json")
    //            do {
    //                let data = try Data(contentsOf: fileURL)
    //                print("getKeyData success?")
    //                return try JSONDecoder().decode(KeyData.self, from: data)
    //            } catch {
    //                throw KeyDataError.decodingError
    //            }
    //        } else {
    //            throw KeyDataError.urlError
    //        }
    //    }
    //
    //
    //    // Delete KeyData WARNING!
    //    func deleteKeyData() {
    //        let fileManager = FileManager.default
    //        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
    //        if let url = urls.first {
    //            let fileURL = url.appendingPathComponent("KeyData.json")
    //            do {
    //                try fileManager.removeItem(at: fileURL)
    //            } catch let error {
    //                debugPrint(error)
    //            }
    //        } else {
    //            debugPrint(KeyDataError.urlError)
    //        }
    //    }
}
