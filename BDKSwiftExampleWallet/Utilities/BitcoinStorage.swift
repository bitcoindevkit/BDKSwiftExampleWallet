//
//  BitcoinStorage.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 3/1/24.
//

import Foundation

struct BitcoinStorage {
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths.first!
    }

    // Unused atm
    func createWalletFile() {
        let fileManager = FileManager.default
        let documentsDirectory = BitcoinStorage().getDocumentsDirectory()
        let walletDataDirectory = documentsDirectory.appendingPathComponent("wallet_data")

        if !fileManager.fileExists(atPath: walletDataDirectory.path) {
            do {
                try fileManager.createDirectory(
                    at: walletDataDirectory,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            } catch {
                return
            }
        }

        let dummyFilePath = walletDataDirectory.appendingPathComponent("dummy.txt")
        let data = "This is a dummy file.".data(using: .utf8)!
        fileManager.createFile(atPath: dummyFilePath.path, contents: data, attributes: nil)
    }

}
