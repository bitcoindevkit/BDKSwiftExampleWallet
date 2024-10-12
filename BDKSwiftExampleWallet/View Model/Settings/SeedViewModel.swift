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

    var seed: BackupInfo?
    var seedViewError: AppError?
    var showingSeedViewErrorAlert: Bool

    init(
        bdkClient: BDKClient = .live,
        seed: BackupInfo? = nil,
        seedViewError: AppError? = nil,
        showingSeedViewErrorAlert: Bool = false
    ) {
        self.bdkClient = bdkClient
        self.seed = seed
        self.seedViewError = seedViewError
        self.showingSeedViewErrorAlert = showingSeedViewErrorAlert
    }

    func getSeed() {
        do {
            let seed = try bdkClient.getBackupInfo()
            self.seed = seed
        } catch {
            self.seedViewError = .generic(message: error.localizedDescription)
            self.showingSeedViewErrorAlert = true
        }
    }

}
