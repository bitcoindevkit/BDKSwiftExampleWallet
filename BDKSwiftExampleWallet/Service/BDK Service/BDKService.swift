//
//  BDKService.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 5/23/23.
//

import BitcoinDevKit
import Foundation

class BDKService {
    static var shared: BDKService = BDKService()

    private var syncMode: SyncMode?
    let keyClient: KeyClient
    private var needsFullScan: Bool = false
    private(set) var network: Network
    private(set) var esploraURL: String

    init(keyClient: KeyClient = .live) {
        self.keyClient = keyClient
        let storedNetworkString = try? keyClient.getNetwork() ?? Network.signet.description
        self.network = Network(stringValue: storedNetworkString ?? "") ?? .signet

        self.esploraURL = (try? keyClient.getEsploraURL()) ?? self.network.url
    }

    func updateNetwork(_ newNetwork: Network) {
        if newNetwork != self.network {
            if (try? keyClient.getBackupInfo()) != nil {
                return
            }

            self.network = newNetwork
            try? keyClient.saveNetwork(newNetwork.description)

            let newURL = newNetwork.url
            updateEsploraURL(newURL)
        }
    }

    func updateEsploraURL(_ newURL: String) {
        if newURL != self.esploraURL {
            self.esploraURL = newURL
            try? keyClient.saveEsploraURL(newURL)
        }
    }

    func updateSyncMode(_ mode: SyncMode) {
        if syncMode != mode {
            self.syncMode = mode
            try? keyClient.saveSyncMode(mode)
        }
    }

    func getSyncMode() -> SyncMode? {
        try? keyClient.getSyncMode()
    }

    func getBackupInfo() throws -> BackupInfo {
        let backupInfo = try keyClient.getBackupInfo()
        return backupInfo
    }
}

extension BDKService {
    func needsFullScanOfWallet() -> Bool {
        return AppStorageUtil.shared.isNeedFullScan ?? true
    }

    func setNeedsFullScan(_ value: Bool) {
        AppStorageUtil.shared.isNeedFullScan = value
    }
}

struct BDKClient {
    let loadWallet: () throws -> Void
    let deleteWallet: () throws -> Void
    let createWalletFromSeed: (String?) throws -> Void
    let createWalletFromDescriptor: (String?) throws -> Void
    let createWalletFromXPub: (String?) throws -> Void
    let getBalance: () throws -> Balance
    let transactions: () throws -> [CanonicalTx]
    let listUnspent: () throws -> [LocalOutput]
    let syncScanWithSyncScanProgress: (@escaping SyncScanProgress) async throws -> Void
    let fullScanWithFullScanProgress: (@escaping FullScanProgress) async throws -> Void
    let getAddress: () throws -> String
    let send: (String, UInt64, UInt64) throws -> Void
    let calculateFee: (Transaction) throws -> Amount
    let calculateFeeRate: (Transaction) throws -> UInt64
    let sentAndReceived: (Transaction) throws -> SentAndReceivedValues
    let buildTransaction: (String, UInt64, UInt64) throws -> Psbt
    let getBackupInfo: () throws -> BackupInfo
    let needsFullScan: () -> Bool
    let setNeedsFullScan: (Bool) -> Void
    let getNetwork: () -> Network
    let getEsploraURL: () -> String
    let updateNetwork: (Network) -> Void
    let updateEsploraURL: (String) -> Void
    let stop: () async throws -> Void
    let upateSyncMode: (SyncMode) -> Void
    let getSyncMode: () -> SyncMode?
}

extension BDKClient {
    static var live: BDKClient {
        do {
            let syncMode = try BDKService.shared.keyClient.getSyncMode()
            if syncMode == .kyoto {
                return .kyoto
            } else {
                return .esplora
            }
        } catch {
            return .esplora
        }
    }
}

#if DEBUG
    extension BDKClient {
        static let mock = Self(
            loadWallet: {},
            deleteWallet: {},
            createWalletFromSeed: { _ in },
            createWalletFromDescriptor: { _ in },
            createWalletFromXPub: { _ in },
            getBalance: { .mock },
            transactions: {
                return [
                    .mock
                ]
            },
            listUnspent: {
                return [
                    .mock
                ]
            },
            syncScanWithSyncScanProgress: { _ in },
            fullScanWithFullScanProgress: { _ in },
            getAddress: { "tb1pd8jmenqpe7rz2mavfdx7uc8pj7vskxv4rl6avxlqsw2u8u7d4gfs97durt" },
            send: { _, _, _ in },
            calculateFee: { _ in Amount.fromSat(satoshi: UInt64(615)) },
            calculateFeeRate: { _ in return UInt64(6.15) },
            sentAndReceived: { _ in
                return SentAndReceivedValues(
                    sent: Amount.fromSat(satoshi: UInt64(20000)),
                    received: Amount.fromSat(satoshi: UInt64(210))
                )
            },
            buildTransaction: { _, _, _ in
                let pb64 = """
                    cHNidP8BAIkBAAAAAeaWcxp4/+xSRJ2rhkpUJ+jQclqocoyuJ/ulSZEgEkaoAQAAAAD+////Ak/cDgAAAAAAIlEgqxShDO8ifAouGyRHTFxWnTjpY69Cssr3IoNQvMYOKG/OVgAAAAAAACJRIGnlvMwBz4Ylb6xLTe5g4ZeZCxmVH/XWG+CDlcPzzaoT8qoGAAABAStAQg8AAAAAACJRIFGGvSoLWt3hRAIwYa8KEyawiFTXoOCVWFxYtSofZuAsIRZ2b8YiEpzexWYGt8B5EqLM8BE4qxJY3pkiGw/8zOZGYxkAvh7sj1YAAIABAACAAAAAgAAAAAAEAAAAARcgdm/GIhKc3sVmBrfAeRKizPAROKsSWN6ZIhsP/MzmRmMAAQUge7cvJMsJmR56NzObGOGkm8vNqaAIJdnBXLZD2PvrinIhB3u3LyTLCZkeejczmxjhpJvLzamgCCXZwVy2Q9j764pyGQC+HuyPVgAAgAEAAIAAAACAAQAAAAYAAAAAAQUgtIFPrI2EW/+PJiAmYdmux88p0KgeAxDFLMoeQoS66hIhB7SBT6yNhFv/jyYgJmHZrsfPKdCoHgMQxSzKHkKEuuoSGQC+HuyPVgAAgAEAAIAAAACAAAAAAAIAAAAA
                    """
                return try! Psbt(psbtBase64: pb64)
            },
            getBackupInfo: {
                BackupInfo(
                    mnemonic:
                        "excite mesh empower noble virus main flee cake gorilla weapon maid radio",
                    descriptor:
                        "tr(tprv8ZgxMBicQKsPdXGCpRXi6PRsH2BaTpP2Aw4K7J5BLVEWHfXYfLZKsPh43VQncqSJucGj6KvzLTNayDcRJEKMfEqLGN1Pi3jjnM7mwRxGQ1s/86\'/1\'/0\'/0/*)#q4yvkz4r",
                    changeDescriptor:
                        "tr(tprv8ZgxMBicQKsPdXGCpRXi6PRsH2BaTpP2Aw4K7J5BLVEWHfXYfLZKsPh43VQncqSJucGj6KvzLTNayDcRJEKMfEqLGN1Pi3jjnM7mwRxGQ1s/86\'/1\'/0\'/1/*)#3ppdth9m"
                )
            },
            needsFullScan: { true },
            setNeedsFullScan: { _ in },
            getNetwork: { .signet },
            getEsploraURL: { Constants.Config.EsploraServerURLNetwork.Signet.mutiny },
            updateNetwork: { _ in },
            updateEsploraURL: { _ in },
            stop: {},
            upateSyncMode: { _ in },
            getSyncMode: { .esplora }
        )
    }
#endif
