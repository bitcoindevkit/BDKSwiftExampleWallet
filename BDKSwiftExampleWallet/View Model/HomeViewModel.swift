//
//  HomeViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 1/24/24.
//

import BitcoinDevKit
import Foundation

@MainActor
@Observable
class HomeViewModel: ObservableObject {
    let bdkClient: BDKClient
    
    let bdkSyncService: BDKSyncService

    var homeViewError: AppError?
    var isWalletLoaded = false
    var showingHomeViewErrorAlert = false

    init(
        bdkClient: BDKClient = .live,
        bdkSyncService: BDKSyncService
    ) {
        self.bdkClient = bdkClient
        self.bdkSyncService = bdkSyncService
    }

    func loadWallet() {
        do {
            try bdkSyncService.loadWallet()
            
            try bdkClient.loadWallet()
            isWalletLoaded = true
        } catch let error as DescriptorError {
            let errorMessage: String
            switch error {
            case .InvalidHdKeyPath:
                errorMessage = "Invalid HD key path"
            case .InvalidDescriptorChecksum:
                errorMessage = "Invalid descriptor checksum"
            case .HardenedDerivationXpub:
                errorMessage = "Hardened derivation with xpub"
            case .MultiPath:
                errorMessage = "Multi-path descriptor"
            case .Key(let message):
                errorMessage = "Key error: \(message)"
            case .Policy(let message):
                errorMessage = "Policy error: \(message)"
            case .InvalidDescriptorCharacter(let char):
                errorMessage = "Invalid descriptor character: \(char)"
            case .Bip32(let message):
                errorMessage = "BIP32 error: \(message)"
            case .Base58(let message):
                errorMessage = "Base58 error: \(message)"
            case .Pk(let message):
                errorMessage = "Public key error: \(message)"
            case .Miniscript(let message):
                errorMessage = "Miniscript error: \(message)"
            case .Hex(let message):
                errorMessage = "Hex error: \(message)"
            case .ExternalAndInternalAreTheSame:
                errorMessage = "External and internal descriptors are the same"
            }
            self.homeViewError = .generic(message: errorMessage)
            self.showingHomeViewErrorAlert = true
        } catch let error as LoadWithPersistError {
            let errorMessage: String
            switch error {
            case .Persist(let message):
                errorMessage = "Persist error: \(message)"
            case .InvalidChangeSet(let message):
                errorMessage = "Invalid change set: \(message)"
            case .CouldNotLoad:
                errorMessage = "Could not load wallet"
            }
            self.homeViewError = .generic(message: errorMessage)
            self.showingHomeViewErrorAlert = true
        } catch let error as KeyServiceError {
            self.homeViewError = .generic(message: error.localizedDescription)
            self.showingHomeViewErrorAlert = true
        } catch {
            self.homeViewError = .generic(message: error.localizedDescription)
            self.showingHomeViewErrorAlert = true
        }
    }

}
