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
    let bdkService: BDKClient
    let keyService: KeyClient

    var seed: BackupInfo?
    var seedViewError: AppError?
    var showingSeedViewErrorAlert: Bool

    init(
        bdkService: BDKClient = .live,
        keyService: KeyClient = .live,
        seed: BackupInfo? = nil,
        seedViewError: AppError? = nil,
        showingSeedViewErrorAlert: Bool = false
    ) {
        self.bdkService = bdkService
        self.keyService = keyService
        self.seed = seed
        self.seedViewError = seedViewError
        self.showingSeedViewErrorAlert = showingSeedViewErrorAlert
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
