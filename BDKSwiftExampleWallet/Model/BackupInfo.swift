//
//  BackupInfo.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/5/23.
//

import Foundation

struct BackupInfo: Codable {
    var mnemonic: String
    var descriptor: String
    var changeDescriptor: String
    
    init(mnemonic: String, descriptor: String, changeDescriptor: String) {
        self.mnemonic = mnemonic
        self.descriptor = descriptor
        self.changeDescriptor = changeDescriptor
    }
}
