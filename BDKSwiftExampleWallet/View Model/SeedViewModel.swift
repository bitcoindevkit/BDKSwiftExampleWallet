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
    var seed: BackupInfo = .init(mnemonic: "", descriptor: "", changeDescriptor: "")
    var seedViewError: AppError?
    var showingSeedViewErrorAlert = false

    func getSeed() {
        do {
            let seed = try BDKClient.live.getBackupInfo()
            self.seed = seed
        } catch {
            self.seedViewError = .generic(message: error.localizedDescription)
            self.showingSeedViewErrorAlert = true
        }
    }

}
