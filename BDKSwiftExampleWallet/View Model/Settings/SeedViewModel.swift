//
//  SeedViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 1/31/24.
//

import BitcoinDevKit
import Foundation
import SwiftUI

@Observable
@MainActor
class SeedViewModel {
    let bdkClient: BDKClient

    var backupInfo: BackupInfo?
    var publicDescriptor: Descriptor?
    var publicChangeDescriptor: Descriptor?
    var seedViewError: AppError?
    var showingSeedViewErrorAlert: Bool

    init(
        bdkClient: BDKClient = .live,
        backupInfo: BackupInfo? = nil,
        seedViewError: AppError? = nil,
        showingSeedViewErrorAlert: Bool = false
    ) {
        self.bdkClient = bdkClient
        self.backupInfo = backupInfo
        self.seedViewError = seedViewError
        self.showingSeedViewErrorAlert = showingSeedViewErrorAlert
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
            self.seedViewError = .generic(message: error.localizedDescription)
            self.showingSeedViewErrorAlert = true
        }
    }

}
