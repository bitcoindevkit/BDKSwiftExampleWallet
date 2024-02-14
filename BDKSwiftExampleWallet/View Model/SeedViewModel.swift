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
    var seedViewError: BdkError?
    var showingSeedViewErrorAlert = false

    func getSeed() {
        do {
            let seed = try BDKClient.live.getBackupInfo()
            self.seed = seed
        } catch _ as BdkError {
            self.seedViewError = BdkError.Generic(message: "Could not show seed")
            self.showingSeedViewErrorAlert = true
        } catch {
            self.seedViewError = BdkError.Generic(message: "Could not show seed")
            self.showingSeedViewErrorAlert = true
        }
    }

}
