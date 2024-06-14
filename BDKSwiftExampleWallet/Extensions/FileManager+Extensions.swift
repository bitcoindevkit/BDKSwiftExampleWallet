//
//  FileManager+Extensions.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 5/9/24.
//

import Foundation

extension FileManager {

    func deleteAllContentsInDocumentsDirectory() throws {
        let documentsURL = URL.documentsDirectory
        let contents = try contentsOfDirectory(
            at: documentsURL,
            includingPropertiesForKeys: nil,
            options: []
        )
        for fileURL in contents {
            try removeItem(at: fileURL)
        }
    }
}
