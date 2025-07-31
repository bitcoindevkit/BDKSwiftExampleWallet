//
//  OnboardingViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/6/23.
//

import BitcoinDevKit
import Foundation
import SwiftUI

// Can't make @Observable yet
// https://developer.apple.com/forums/thread/731187
// Feature or Bug?
class OnboardingViewModel: ObservableObject {
    let bdkClient: BDKClient

    @AppStorage("isOnboarding") var isOnboarding: Bool?
    @Published var createWithPersistError: CreateWithPersistError?
    @Published var isCreatingWallet = false
    var isDescriptor: Bool {
        words.hasPrefix("tr(") || words.hasPrefix("wpkh(") || words.hasPrefix("wsh(")
            || words.hasPrefix("sh(")
    }
    var isXPub: Bool {
        words.hasPrefix("xpub") || words.hasPrefix("tpub") || words.hasPrefix("vpub")
    }
    @Published var networkColor = Color.gray
    @Published var onboardingViewError: AppError?
    @Published var selectedNetwork: Network = .signet {
        didSet {
            guard !isInitializing else { return }
            bdkClient.updateNetwork(selectedNetwork)
            // If switching away from Signet and Kyoto is selected, switch to Esplora
            if selectedNetwork != .signet && selectedClientType == .kyoto {
                selectedClientType = .esplora
            }
            if selectedClientType == .esplora {
                selectedURL = availableURLs.first ?? ""
            } else if selectedClientType == .kyoto {
                // Set to a valid Esplora URL to avoid picker warnings, even though Kyoto won't use it
                selectedURL = availableURLs.first ?? ""
            }
        }
    }
    @Published var selectedURL: String = "" {
        didSet {
            guard !isInitializing else { return }
            // Only update Esplora URL for Esplora clients
            if selectedClientType == .esplora {
                bdkClient.updateEsploraURL(selectedURL)
            }
        }
    }
    @Published var selectedAddressType: AddressType = .bip86 {
        didSet {
            guard !isInitializing else { return }
            bdkClient.updateAddressType(selectedAddressType)
        }
    }
    @Published var selectedClientType: BlockchainClientType = .esplora {
        didSet {
            guard !isInitializing else { return }
            bdkClient.updateClientType(selectedClientType)
            // When switching client types, update URL appropriately
            if selectedClientType == .kyoto {
                // Set to a valid Esplora URL to avoid picker warnings, even though Kyoto won't use it
                selectedURL = availableURLs.first ?? ""
            } else if selectedClientType == .esplora {
                selectedURL = availableURLs.first ?? ""
            }
        }
    }
    @Published var words: String = ""
    var wordArray: [String] {
        if words.hasPrefix("xpub") || words.hasPrefix("tpub") || words.hasPrefix("vpub") {
            return []
        }
        let trimmedWords = words.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedWords.components(separatedBy: " ")
    }
    var availableURLs: [String] {
        switch selectedNetwork {
        case .bitcoin:
            return Constants.Networks.Bitcoin.esploraServers
        case .testnet:
            return Constants.Networks.Testnet.esploraServers
        case .regtest:
            return Constants.Networks.Regtest.esploraServers
        case .signet:
            return Constants.Networks.Signet.allEsploraServers
        case .testnet4:
            return Constants.Networks.Testnet4.esploraServers
        }
    }
    var buttonColor: Color {
        switch selectedNetwork {
        case .bitcoin:
            return Constants.BitcoinNetworkColor.bitcoin.color
        case .testnet:
            return Constants.BitcoinNetworkColor.testnet.color
        case .signet:
            return Constants.BitcoinNetworkColor.signet.color
        case .regtest:
            return Constants.BitcoinNetworkColor.regtest.color
        case .testnet4:
            return Constants.BitcoinNetworkColor.testnet4.color
        }
    }

    private var isInitializing = true

    init(
        bdkClient: BDKClient = .live
    ) {
        self.bdkClient = bdkClient

        // Set properties during initialization to avoid didSet side effects
        self.selectedNetwork = bdkClient.getNetwork()
        self.selectedAddressType = bdkClient.getAddressType()
        self.selectedClientType = bdkClient.getClientType()

        // Always set to Esplora URL for UI consistency (Kyoto will use peer internally)
        self.selectedURL = bdkClient.getEsploraURL()

        isInitializing = false
    }

    func createWallet() {
        // Check if wallet already exists
        if let existingBackup = try? bdkClient.getBackupInfo() {
            DispatchQueue.main.async {
                self.isOnboarding = false
            }
            return
        }

        guard !isCreatingWallet else {
            return
        }

        DispatchQueue.main.async {
            self.isCreatingWallet = true
        }

        Task {
            do {
                if self.isDescriptor {
                    try self.bdkClient.createWalletFromDescriptor(self.words)
                } else if self.isXPub {
                    try self.bdkClient.createWalletFromXPub(self.words)
                } else {
                    try self.bdkClient.createWalletFromSeed(self.words)
                }
                DispatchQueue.main.async {
                    self.isCreatingWallet = false
                    self.isOnboarding = false
                    NotificationCenter.default.post(name: .walletCreated, object: nil)
                }
            } catch let error as CreateWithPersistError {
                DispatchQueue.main.async {
                    self.isCreatingWallet = false
                    self.createWithPersistError = error
                }
            } catch {
                DispatchQueue.main.async {
                    self.isCreatingWallet = false
                    self.onboardingViewError = .generic(message: error.localizedDescription)
                }
            }
        }
    }
}
