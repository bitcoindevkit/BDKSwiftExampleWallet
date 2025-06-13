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

    func deleteAllData() throws {
        try deleteNetwork()
        try deleteBackupInfo()
        try deleteEsploraURL()
    }

    func saveSyncMode(_ mode: SyncMode) throws {
        keychain[string: "SyncMode"] = mode.rawValue
    }

    func getSyncMode() throws -> SyncMode? {
        guard let mode = keychain[string: "SyncMode"] else {
            return nil
        }
        return SyncMode(rawValue: mode)
    }
}

struct KeyClient {
    let deleteBackupInfo: () throws -> Void
    let deleteEsplora: () throws -> Void
    let deleteNetwork: () throws -> Void
    let getBackupInfo: () throws -> BackupInfo
    let getEsploraURL: () throws -> String?
    let getNetwork: () throws -> String?
    let saveEsploraURL: (String) throws -> Void
    let saveBackupInfo: (BackupInfo) throws -> Void
    let saveNetwork: (String) throws -> Void
    let deleteAllData: () throws -> Void
    let saveSyncMode: (SyncMode) throws -> Void
    let getSyncMode: () throws -> SyncMode?

    private init(
        deleteBackupInfo: @escaping () throws -> Void,
        deleteEsplora: @escaping () throws -> Void,
        deleteNetwork: @escaping () throws -> Void,
        getBackupInfo: @escaping () throws -> BackupInfo,
        getEsploraURL: @escaping () throws -> String?,
        getNetwork: @escaping () throws -> String?,
        saveBackupInfo: @escaping (BackupInfo) throws -> Void,
        saveEsploraURL: @escaping (String) throws -> Void,
        saveNetwork: @escaping (String) throws -> Void,
        deleteAllData: @escaping () throws -> Void,
        saveSyncMode: @escaping (SyncMode) throws -> Void,
        getSyncMode: @escaping () throws -> SyncMode?
    ) {
        self.deleteBackupInfo = deleteBackupInfo
        self.deleteEsplora = deleteEsplora
        self.deleteNetwork = deleteNetwork
        self.getBackupInfo = getBackupInfo
        self.getEsploraURL = getEsploraURL
        self.getNetwork = getNetwork
        self.saveBackupInfo = saveBackupInfo
        self.saveEsploraURL = saveEsploraURL
        self.saveNetwork = saveNetwork
        self.deleteAllData = deleteAllData
        self.saveSyncMode = saveSyncMode
        self.getSyncMode = getSyncMode
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
        saveBackupInfo: { backupInfo in try KeyService().saveBackupInfo(backupInfo: backupInfo) },
        saveEsploraURL: { url in try KeyService().saveEsploraURL(url: url) },
        saveNetwork: { network in try KeyService().saveNetwork(network: network) },
        deleteAllData: { try KeyService().deleteAllData() },
        saveSyncMode: { mode in try KeyService().saveSyncMode(mode) },
        getSyncMode: { try KeyService().getSyncMode() }
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
                    keychain: .external,
                    network: mockKeyClientNetwork
                )
                let changeDescriptor = Descriptor.newBip86(
                    secretKey: secretKey,
                    keychain: .internal,
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
            saveBackupInfo: { _ in },
            saveEsploraURL: { _ in },
            saveNetwork: { _ in },
            deleteAllData: {},
            saveSyncMode: { _ in },
            getSyncMode: { .esplora }
        )
    }
#endif
