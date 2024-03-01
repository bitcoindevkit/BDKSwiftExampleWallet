//
//  BitcoinStorage.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 3/1/24.
//

import Foundation

struct BitcoinStorage {
    func getDocumentsDirectory() -> URL {
        // This gets the first URL for the documents directory, which is what you want.
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths.first!
    }

    

    func createDummyFile() {
        let fileManager = FileManager.default
        let documentsDirectory = BitcoinStorage().getDocumentsDirectory()
        let walletDataDirectory = documentsDirectory.appendingPathComponent("wallet_data")

        // Check if the wallet_data directory exists, if not, create it
        if !fileManager.fileExists(atPath: walletDataDirectory.path) {
            do {
                try fileManager.createDirectory(at: walletDataDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Failed to create wallet_data directory: \(error)")
                return
            }
        }

        let dummyFilePath = walletDataDirectory.appendingPathComponent("dummy.txt")
        let data = "This is a dummy file.".data(using: .utf8)!
        fileManager.createFile(atPath: dummyFilePath.path, contents: data, attributes: nil)
    }


}
