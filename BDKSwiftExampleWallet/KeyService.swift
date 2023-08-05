//
//  KeyService.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/4/23.
//

import Foundation

struct KeyService {
    // Save KeyData as file
    func saveKeyData(keyData: KeyData) throws {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        if let url = urls.first {
            let fileURL = url.appendingPathComponent("KeyData.json")
            if let jsonData = try? JSONEncoder().encode(keyData) {
                do {
                    try jsonData.write(to: fileURL, options: [.atomicWrite])
                    print("saveKeyData success")
                } catch {
                    throw KeyDataError.writeError
                }
            } else  {
                throw KeyDataError.encodingError
            }
        } else {
            throw KeyDataError.urlError
        }
    }

    // Get KeyData from file
    func getKeyData() throws -> KeyData {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        if let url = urls.first {
            let fileURL = url.appendingPathComponent("KeyData.json")
            do {
                let data = try Data(contentsOf: fileURL)
                print("getKeyData success?")
                return try JSONDecoder().decode(KeyData.self, from: data)
            } catch {
                throw KeyDataError.decodingError
            }
        } else {
            throw KeyDataError.urlError
        }
    }

    // Delete KeyData WARNING!
    func deleteKeyData() {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        if let url = urls.first {
            let fileURL = url.appendingPathComponent("KeyData.json")
            do {
                try fileManager.removeItem(at: fileURL)
            } catch let error {
                debugPrint(error)
            }
        } else {
            debugPrint(KeyDataError.urlError)
        }
    }

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

//// Save KeyData as file
//func saveKeyData(keyData: KeyData) throws {
//    let fileManager = FileManager.default
//    let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
//    if let url = urls.first {
//        let fileURL = url.appendingPathComponent("KeyData.json")
//        if let jsonData = try? JSONEncoder().encode(keyData) {
//            do {
//                try jsonData.write(to: fileURL, options: [.atomicWrite])
//                print("saveKeyData success")
//            } catch {
//                throw KeyDataError.writeError
//            }
//        } else  {
//            throw KeyDataError.encodingError
//        }
//    } else {
//        throw KeyDataError.urlError
//    }
//}
//
//// Get KeyData from file
//func getKeyData() throws -> KeyData {
//    let fileManager = FileManager.default
//    let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
//    if let url = urls.first {
//        let fileURL = url.appendingPathComponent("KeyData.json")
//        do {
//            let data = try Data(contentsOf: fileURL)
//            print("getKeyData success?")
//            return try JSONDecoder().decode(KeyData.self, from: data)
//        } catch {
//            throw KeyDataError.decodingError
//        }
//    } else {
//        throw KeyDataError.urlError
//    }
//}
//
//// Delete KeyData WARNING!
//func deleteKeyData() {
//    let fileManager = FileManager.default
//    let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
//    if let url = urls.first {
//        let fileURL = url.appendingPathComponent("KeyData.json")
//        do {
//            try fileManager.removeItem(at: fileURL)
//        } catch let error {
//            debugPrint(error)
//        }
//    } else {
//        debugPrint(KeyDataError.urlError)
//    }
//}
//
//enum KeyDataError: Error {
//    case encodingError
//    case writeError
//    case urlError
//    case decodingError
//    case readError
//}
