//
//  SettingsViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 1/24/24.
//

import BitcoinDevKit
import Foundation
import SwiftUI

class SettingsViewModel: ObservableObject {
    let bdkClient: BDKClient

    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    @Published var esploraURL: String?
    @Published var inspectedScripts: UInt64 = 0
    @Published var network: String?
    @Published var settingsError: AppError?
    @Published var showingSettingsViewErrorAlert = false
    @Published var walletSyncState: WalletSyncState = .notStarted

    init(
        bdkClient: BDKClient = .live
    ) {
        self.bdkClient = bdkClient
        print("SettingsViewModel: Initializing")
        self.network = bdkClient.getNetwork().description
        self.esploraURL = bdkClient.getEsploraURL()
        print(
            "SettingsViewModel: Initialized with network \(self.network ?? "nil") and URL \(self.esploraURL ?? "nil")"
        )
    }

    func delete() {
        print("SettingsViewModel: Deleting wallet")
        do {
            try bdkClient.deleteWallet()
            isOnboarding = true
            print("SettingsViewModel: Wallet deleted successfully")
        } catch {
            print("SettingsViewModel: Error deleting wallet - \(error.localizedDescription)")
            self.settingsError = .generic(message: error.localizedDescription)
            self.showingSettingsViewErrorAlert = true
        }
    }

    func fullScanWithProgress() async {
        DispatchQueue.main.async {
            self.walletSyncState = .syncing
        }
        do {
            let inspector = WalletFullScanScriptInspector(updateProgress: updateProgressFullScan)
            try await bdkClient.fullScanWithInspector(inspector)
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
        print("SettingsViewModel: Retrieved network - \(self.network ?? "nil")")
    }

    func getEsploraUrl() {
        self.esploraURL = bdkClient.getEsploraURL()
        print("SettingsViewModel: Retrieved Esplora URL - \(self.esploraURL ?? "nil")")
    }

    //    func getNetwork() {
    //        do {
    //            self.network = try keyClient.getNetwork()
    //        } catch {
    //            DispatchQueue.main.async {
    //                self.settingsError = .generic(message: error.localizedDescription)
    //                self.showingSettingsViewErrorAlert = true
    //            }
    //        }
    //    }
    //
    //    func getEsploraUrl() {
    //        do {
    //            self.esploraURL = try keyClient.getEsploraURL()
    //        } catch {
    //            DispatchQueue.main.async {
    //                self.settingsError = .generic(message: error.localizedDescription)
    //            }
    //        }
    //    }

    private func updateProgressFullScan(inspected: UInt64) {
        DispatchQueue.main.async {
            self.inspectedScripts = inspected
        }
    }

}
