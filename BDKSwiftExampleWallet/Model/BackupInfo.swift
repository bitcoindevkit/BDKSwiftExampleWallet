//
//  BackupInfo.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/5/23.
//

import Foundation

struct BackupInfo: Codable, Equatable {
    var mnemonic: String
    var descriptor: String
    var changeDescriptor: String

    init(mnemonic: String, descriptor: String, changeDescriptor: String) {
        self.mnemonic = mnemonic
        self.descriptor = descriptor
        self.changeDescriptor = changeDescriptor
    }

    static func == (lhs: BackupInfo, rhs: BackupInfo) -> Bool {
        return lhs.mnemonic == rhs.mnemonic && lhs.descriptor == rhs.descriptor
            && lhs.changeDescriptor == rhs.changeDescriptor
    }
}

#if DEBUG
    extension BackupInfo {
        static var mock = Self(
            mnemonic:
                "space echo position wrist orient erupt relief museum myself grain wisdom tumble",
            descriptor: "",
            changeDescriptor: ""
        )
    }
#endif
