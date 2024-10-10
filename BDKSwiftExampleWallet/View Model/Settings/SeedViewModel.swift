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

    var backupInfo: BackupInfo?
    var seedViewError: AppError?
    var showingSeedViewErrorAlert: Bool

    init(
        bdkService: BDKClient = .live,
        keyService: KeyClient = .live,
        backupInfo: BackupInfo? = nil,
        seedViewError: AppError? = nil,
        showingSeedViewErrorAlert: Bool = false
    ) {
        self.bdkService = bdkService
        self.keyService = keyService
        self.backupInfo = backupInfo
        self.seedViewError = seedViewError
        self.showingSeedViewErrorAlert = showingSeedViewErrorAlert
    }
    
    func getNetwork() {
        
    }

    func getBackupInfo() {
        do {
            let backupInfo = try bdkService.getBackupInfo()
            
            let externalPublicDescriptor = try Descriptor.init(descriptor: backupInfo.descriptor, network: .signet)
            print("externalPublicDescriptor: \(externalPublicDescriptor)")
            
            let internalPublicDescriptor = try Descriptor.init(descriptor: backupInfo.changeDescriptor, network: .signet)
            print("internalPublicDescriptor: \(internalPublicDescriptor)")
            
            self.backupInfo = backupInfo
        } catch {
            self.seedViewError = .generic(message: error.localizedDescription)
            self.showingSeedViewErrorAlert = true
        }
    }

}
