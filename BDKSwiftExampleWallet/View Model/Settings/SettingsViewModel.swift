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
    @Published var settingsError: AppError?
    @Published var showingSettingsViewErrorAlert = false
    @Published var walletSyncState: WalletSyncState = .notStarted

    private var updateProgressFullScan: @Sendable (UInt64) -> Void {
        { [weak self] inspected in
            DispatchQueue.main.async {
                self?.inspectedScripts = inspected
            }
        }
    }

    init(
        bdkClient: BDKClient = .live
    ) {
        self.bdkClient = bdkClient
        self.network = bdkClient.getNetwork().description
        self.esploraURL = bdkClient.getEsploraURL()
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
        DispatchQueue.main.async {
            self.walletSyncState = .syncing
        }
        do {
            try await bdkClient.fullScanWithFullScanProgress { [weak self] progress in
                DispatchQueue.main.async {
                    self?.inspectedScripts = progress
                }
            }
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: Notification.Name("TransactionSent"),
                    object: nil
                )
                self.walletSyncState = .synced
            }
        } catch let error as CannotConnectError {
            DispatchQueue.main.async {
                self.settingsError = .generic(message: error.localizedDescription)
                self.showingSettingsViewErrorAlert = true
            }
        } catch let error as EsploraError {
            DispatchQueue.main.async {
                self.settingsError = .generic(message: error.localizedDescription)
                self.showingSettingsViewErrorAlert = true
            }
        } catch let error as PersistenceError {
            DispatchQueue.main.async {
                self.settingsError = .generic(message: error.localizedDescription)
                self.showingSettingsViewErrorAlert = true
            }
        } catch {
            DispatchQueue.main.async {
                self.walletSyncState = .error(error)
                self.showingSettingsViewErrorAlert = true
            }
        }
    }

    func getNetwork() {
        self.network = bdkClient.getNetwork().description
    }

    func getEsploraUrl() {
        self.esploraURL = bdkClient.getEsploraURL()
    }
}
