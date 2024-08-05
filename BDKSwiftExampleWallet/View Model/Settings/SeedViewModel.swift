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
    var seed: BackupInfo?
    var seedViewError: AppError?
    var showingSeedViewErrorAlert: Bool
    let bdkService: BDKClient

    init(
        seed: BackupInfo? = nil,
        seedViewError: AppError? = nil,
        showingSeedViewErrorAlert: Bool = false,
        bdkService: BDKClient = .live
    ) {
        self.seed = seed
        self.seedViewError = seedViewError
        self.showingSeedViewErrorAlert = showingSeedViewErrorAlert
        self.bdkService = bdkService
    }

    func getSeed() {
        do {
            let seed = try bdkService.getBackupInfo()
            self.seed = seed
        } catch {
            self.seedViewError = .generic(message: error.localizedDescription)
            self.showingSeedViewErrorAlert = true
        }
    }

}
