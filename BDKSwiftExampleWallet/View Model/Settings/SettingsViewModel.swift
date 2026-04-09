//
//  SettingsViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 1/24/24.
//

import BitcoinDevKit
import Foundation
import SwiftUI

@MainActor
class SettingsViewModel: ObservableObject {
    let bdkClient: BDKClient

    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    @Published var esploraURL: String?
    @Published var inspectedScripts: UInt64 = 0
    @Published var network: String?
    @Published var addressType: AddressType?
    @Published var settingsError: AppError?
    @Published var showingSettingsViewErrorAlert = false
    @Published var walletSyncState: WalletSyncState = .notStarted

    private var updateProgressFullScan: @Sendable (UInt64) -> Void {
        { [weak self] inspected in
            Task { @MainActor [weak self] in
                self?.inspectedScripts = inspected
            }
        }
    }

    init(
        bdkClient: BDKClient = .live
    ) {
        self.bdkClient = bdkClient
        self.network = bdkClient.getNetwork().description
        self.addressType = bdkClient.getAddressType()

        let clientType = bdkClient.getClientType()
        if clientType == .kyoto {
            self.esploraURL = "Kyoto (P2P)"
        } else {
            self.esploraURL = bdkClient.getEsploraURL()
        }
    }

    func getAddressType() {
        self.addressType = self.bdkClient.getAddressType()
    }

    func delete() {
        do {
            try bdkClient.deleteWallet()
            isOnboarding = true
        } catch {
            self.settingsError = .generic(message: error.localizedDescription)
            self.showingSettingsViewErrorAlert = true
        }
    }

    func fullScanWithProgress() async {
        self.walletSyncState = .syncing
        do {
            let inspector = WalletFullScanScriptInspector(updateProgress: updateProgressFullScan)
            try await bdkClient.fullScanWithInspector(inspector)
            NotificationCenter.default.post(
                name: .transactionSent,
                object: nil
            )
            self.walletSyncState = .synced
        } catch let error as CannotConnectError {
            self.settingsError = .generic(message: error.localizedDescription)
            self.showingSettingsViewErrorAlert = true
        } catch let error as EsploraError {
            self.settingsError = .generic(message: error.localizedDescription)
            self.showingSettingsViewErrorAlert = true
        } catch let error as PersistenceError {
            self.settingsError = .generic(message: error.localizedDescription)
            self.showingSettingsViewErrorAlert = true
        } catch {
            self.walletSyncState = .error(error)
            self.showingSettingsViewErrorAlert = true
        }
    }

    func getNetwork() {
        self.network = bdkClient.getNetwork().description
    }

    func getEsploraUrl() {
        let clientType = bdkClient.getClientType()
        if clientType == .kyoto {
            self.esploraURL = "Kyoto (P2P)"
        } else {
            self.esploraURL = bdkClient.getEsploraURL()
        }
    }
}
