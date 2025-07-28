//
//  KeyService.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/4/23.
//

import BitcoinDevKit
import Foundation
import KeychainAccess

private struct KeyService {
    private let keychain: Keychain

    init() {
        let keychain = Keychain(service: "com.matthewramsden.bdkswiftexamplewallet.testservice")
            .label(Bundle.main.displayName)
            .synchronizable(false)
            .accessibility(.whenUnlocked)
        self.keychain = keychain
    }

    func deleteBackupInfo() throws {
        try keychain.remove("BackupInfo")
    }

    func deleteEsploraURL() throws {
        try keychain.remove("SelectedEsploraURL")
    }

    func deleteNetwork() throws {
        try keychain.remove("SelectedNetwork")
    }

    func getBackupInfo() throws -> BackupInfo {
        guard let encryptedJsonData = try keychain.getData("BackupInfo") else {
            throw KeyServiceError.readError
        }
        let decoder = JSONDecoder()
        let backupInfo = try decoder.decode(BackupInfo.self, from: encryptedJsonData)
        return backupInfo
    }

    func getEsploraURL() throws -> String? {
        return keychain[string: "SelectedEsploraURL"]
    }

    func getNetwork() throws -> String? {
        return keychain[string: "SelectedNetwork"]
    }

    func saveBackupInfo(backupInfo: BackupInfo) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(backupInfo)
        keychain[data: "BackupInfo"] = data
    }

    func saveEsploraURL(url: String) throws {
        keychain[string: "SelectedEsploraURL"] = url
    }

    func saveNetwork(network: String) throws {
        keychain[string: "SelectedNetwork"] = network
    }

    func getAddressType() throws -> String? {
        return keychain[string: "SelectedAddressType"]
    }

    func saveAddressType(addressType: String) throws {
        keychain[string: "SelectedAddressType"] = addressType
    }
    
    func getClientType() throws -> String? {
        return keychain[string: "SelectedClientType"]
    }
    
    func saveClientType(_ clientType: String) throws {
        keychain[string: "SelectedClientType"] = clientType
    }
}

struct KeyClient {
    let deleteBackupInfo: () throws -> Void
    let deleteEsplora: () throws -> Void
    let deleteNetwork: () throws -> Void
    let getBackupInfo: () throws -> BackupInfo
    let getEsploraURL: () throws -> String?
    let getNetwork: () throws -> String?
    let getAddressType: () throws -> String?
    let saveEsploraURL: (String) throws -> Void
    let saveBackupInfo: (BackupInfo) throws -> Void
    let saveNetwork: (String) throws -> Void
    let saveAddressType: (String) throws -> Void
    let getClientType: () throws -> BlockchainClientType
    let saveClientType: (BlockchainClientType) throws -> Void

    private init(
        deleteBackupInfo: @escaping () throws -> Void,
        deleteEsplora: @escaping () throws -> Void,
        deleteNetwork: @escaping () throws -> Void,
        getBackupInfo: @escaping () throws -> BackupInfo,
        getEsploraURL: @escaping () throws -> String?,
        getNetwork: @escaping () throws -> String?,
        getAddressType: @escaping () throws -> String?,
        saveBackupInfo: @escaping (BackupInfo) throws -> Void,
        saveEsploraURL: @escaping (String) throws -> Void,
        saveNetwork: @escaping (String) throws -> Void,
        saveAddressType: @escaping (String) throws -> Void,
        getClientType: @escaping () throws -> BlockchainClientType,
        saveClientType: @escaping (BlockchainClientType) throws -> Void
    ) {
        self.deleteBackupInfo = deleteBackupInfo
        self.deleteEsplora = deleteEsplora
        self.deleteNetwork = deleteNetwork
        self.getBackupInfo = getBackupInfo
        self.getEsploraURL = getEsploraURL
        self.getNetwork = getNetwork
        self.getAddressType = getAddressType
        self.saveBackupInfo = saveBackupInfo
        self.saveEsploraURL = saveEsploraURL
        self.saveNetwork = saveNetwork
        self.saveAddressType = saveAddressType
        self.getClientType = getClientType
        self.saveClientType = saveClientType
    }
}

extension KeyClient {
    static let live = Self(
        deleteBackupInfo: { try KeyService().deleteBackupInfo() },
        deleteEsplora: { try KeyService().deleteEsploraURL() },
        deleteNetwork: { try KeyService().deleteNetwork() },
        getBackupInfo: { try KeyService().getBackupInfo() },
        getEsploraURL: { try KeyService().getEsploraURL() },
        getNetwork: { try KeyService().getNetwork() },
        getAddressType: { try KeyService().getAddressType() },
        saveBackupInfo: { backupInfo in try KeyService().saveBackupInfo(backupInfo: backupInfo) },
        saveEsploraURL: { url in try KeyService().saveEsploraURL(url: url) },
        saveNetwork: { network in try KeyService().saveNetwork(network: network) },
        saveAddressType: { addressType in try KeyService().saveAddressType(addressType: addressType) },
        getClientType: {
            let raw = try KeyService().getClientType()
            return BlockchainClientType(rawValue: raw ?? "") ?? .esplora
        },
        saveClientType: { type in
            try KeyService().saveClientType(type.rawValue)
        }
    )
}

#if DEBUG
    extension KeyClient {
        static let mock = Self(
            deleteBackupInfo: { try KeyService().deleteBackupInfo() },
            deleteEsplora: {},
            deleteNetwork: {},
            getBackupInfo: {
                let words12 =
                    "space echo position wrist orient erupt relief museum myself grain wisdom tumble"
                let mnemonic = try Mnemonic.fromString(mnemonic: words12)
                let secretKey = DescriptorSecretKey(
                    network: mockKeyClientNetwork,
                    mnemonic: mnemonic,
                    password: nil
                )
                let descriptor = Descriptor.newBip86(
                    secretKey: secretKey,
                    keychainKind: .external,
                    network: mockKeyClientNetwork
                )
                let changeDescriptor = Descriptor.newBip86(
                    secretKey: secretKey,
                    keychainKind: .internal,
                    network: mockKeyClientNetwork
                )
                let backupInfo = BackupInfo(
                    mnemonic: mnemonic.description,
                    descriptor: descriptor.description,
                    changeDescriptor: changeDescriptor.toStringWithSecret()
                )
                return backupInfo
            },
            getEsploraURL: { nil },
            getNetwork: { nil },
            getAddressType: { nil },
            saveBackupInfo: { _ in },
            saveEsploraURL: { _ in },
            saveNetwork: { _ in },
            saveAddressType: { _ in },
            getClientType: { .esplora },
            saveClientType: { _ in }
        )
    }
#endif
