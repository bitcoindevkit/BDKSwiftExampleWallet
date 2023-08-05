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

    enum KeyDataError: Error {
        case encodingError
        case writeError
        case urlError
        case decodingError
        case readError
    }
}

struct KeyData: Codable {
    var mnemonic: String
    var descriptor: String
    var changeDescriptor: String
    
    init(mnemonic: String, descriptor: String, changeDescriptor: String) {
        self.mnemonic = mnemonic
        self.descriptor = descriptor
        self.changeDescriptor = changeDescriptor
    }
}

extension KeyService {
    
    // Get any saved backup info from keychain, decrypted
//    public func getBackupInfo() -> KeyData? {
//        let encryptedJsonData = try? keychain.getData("BackupInfo")
//        if encryptedJsonData != nil {
//            do {
//                let sealedBox = try AES.GCM.SealedBox(combined: encryptedJsonData!)
//                let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)
//                let decryptedJson = String(data: decryptedData, encoding: .utf8)
//                let backupInfo = try JSONDecoder().decode(BackupInfo.self, from: decryptedJson!.data(using: .utf8)!)
//                return backupInfo
//            } catch let error {
//                print(error)
//                return nil
//            }
//        } else {
//            return nil
//        }
//    }
    
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

    // Save backup info to keychain, encrypted
//   func saveBackupInfo(backupInfo: KeyData) {
//        if let json = try? JSONEncoder().encode(backupInfo) {
//            do {
//                let encryptedContent = try AES.GCM.seal(json, using: self.symmetricKey).combined
//                keychain[data: "BackupInfo"] = encryptedContent
//            } catch let error {
//                print(error)
//            }
//        }
//    }
    
    // should I throw here?
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
    
    // Delete backup info from keychain - WARNING!
    func deleteBackupInfo() throws {
        do {
            try keychain.remove("BackupInfo")
        } catch let error {
            // Handle the error, e.g., print or log it.
            print("Error while deleting BackupInfo: \(error)")
            throw error
        }
    }


}
