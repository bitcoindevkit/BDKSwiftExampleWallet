//
//  WalletRecoveryViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 1/31/24.
//

import BitcoinDevKit
import Foundation
import SwiftUI

@Observable
@MainActor
class WalletRecoveryViewModel {
    let bdkClient: BDKClient

    var backupInfo: BackupInfo?
    var publicDescriptor: Descriptor?
    var publicChangeDescriptor: Descriptor?
    var walletRecoveryViewError: AppError?
    var showingWalletRecoveryViewErrorAlert: Bool

    init(
        bdkClient: BDKClient = .esplora,
        backupInfo: BackupInfo? = nil,
        walletRecoveryViewError: AppError? = nil,
        showingWalletRecoveryViewErrorAlert: Bool = false
    ) {
        self.bdkClient = bdkClient
        self.backupInfo = backupInfo
        self.walletRecoveryViewError = walletRecoveryViewError
        self.showingWalletRecoveryViewErrorAlert = showingWalletRecoveryViewErrorAlert
    }

    func getNetwork() -> Network {
        let savedNetwork = bdkClient.getNetwork()
        return savedNetwork
    }

    func getBackupInfo(network: Network) {
        do {
            let backupInfo = try bdkClient.getBackupInfo()

            let externalPublicDescriptor = try Descriptor.init(
                descriptor: backupInfo.descriptor,
                network: network
            )
            self.publicDescriptor = externalPublicDescriptor

            let internalPublicDescriptor = try Descriptor.init(
                descriptor: backupInfo.changeDescriptor,
                network: network
            )
            self.publicChangeDescriptor = internalPublicDescriptor

            self.backupInfo = backupInfo
        } catch {
            self.walletRecoveryViewError = .generic(message: error.localizedDescription)
            self.showingWalletRecoveryViewErrorAlert = true
        }
    }

}
