//
//  OnboardingViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/6/23.
//

import BitcoinDevKit
import Foundation
import SwiftUI

struct TimeoutError: Error {}

func withTimeout<T>(seconds: TimeInterval, operation: @escaping () throws -> T) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask {
            return try operation()
        }

        group.addTask {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            throw TimeoutError()
        }

        let result = try await group.next()!
        group.cancelAll()
        return result
    }
}

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
            bdkClient.updateNetwork(selectedNetwork)
            selectedURL = availableURLs.first ?? ""
            bdkClient.updateEsploraURL(selectedURL)
        }
    }
    @Published var selectedURL: String = "" {
        didSet {
            bdkClient.updateEsploraURL(selectedURL)
        }
    }
    @Published var selectedAddressType: AddressType = .bip86 {
        didSet {
            bdkClient.updateAddressType(selectedAddressType)
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
            return Constants.Config.EsploraServerURLNetwork.Bitcoin.allValues
        case .testnet:
            return Constants.Config.EsploraServerURLNetwork.Testnet.allValues
        case .regtest:
            return Constants.Config.EsploraServerURLNetwork.Regtest.allValues
        case .signet:
            return Constants.Config.EsploraServerURLNetwork.Signet.allValues
        case .testnet4:
            return Constants.Config.EsploraServerURLNetwork.Testnet4.allValues
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

    init(
        bdkClient: BDKClient = .live
    ) {
        self.bdkClient = bdkClient
        self.selectedNetwork = bdkClient.getNetwork()
        self.selectedURL = bdkClient.getEsploraURL()
        self.selectedAddressType = bdkClient.getAddressType()
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
                try await withTimeout(seconds: 30) {
                    if self.isDescriptor {
                        try self.bdkClient.createWalletFromDescriptor(self.words)
                    } else if self.isXPub {
                        try self.bdkClient.createWalletFromXPub(self.words)
                    } else {
                        try self.bdkClient.createWalletFromSeed(self.words)
                    }
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
            } catch is TimeoutError {
                DispatchQueue.main.async {
                    self.isCreatingWallet = false
                    self.onboardingViewError = .generic(
                        message: "Wallet creation timed out. Please try again."
                    )
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
