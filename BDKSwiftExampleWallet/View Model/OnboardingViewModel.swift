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
    let keyClient: KeyClient

    @AppStorage("isOnboarding") var isOnboarding: Bool?
    @Published var createWithPersistError: CreateWithPersistError?
    @Published var networkColor = Color.gray
    @Published var onboardingViewError: AppError?
    @Published var selectedNetwork: Network = .signet {
        didSet {
            do {
                let networkString = selectedNetwork.description
                try keyClient.saveNetwork(networkString)
                selectedURL = availableURLs.first ?? ""
                try keyClient.saveEsploraURL(selectedURL)
            } catch {
                DispatchQueue.main.async {
                    self.onboardingViewError = .generic(message: error.localizedDescription)
                }
            }
        }
    }
    @Published var selectedURL: String = "" {
        didSet {
            do {
                try keyClient.saveEsploraURL(selectedURL)
            } catch {
                DispatchQueue.main.async {
                    self.onboardingViewError = .generic(message: error.localizedDescription)
                }
            }
        }
    }
    @Published var words: String = "" {
        didSet {
            updateWordArray()
        }
    }
    @Published var wordArray: [String] = []
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
        }
    }

    init(
        bdkClient: BDKClient = .live,
        keyClient: KeyClient = .live
    ) {
        self.bdkClient = bdkClient
        self.keyClient = keyClient
        do {
            if let networkString = try keyClient.getNetwork() {
                self.selectedNetwork = Network(stringValue: networkString) ?? .signet
            } else {
                self.selectedNetwork = .signet
            }
            if let esploraURL = try keyClient.getEsploraURL() {
                self.selectedURL = esploraURL
            } else {
                self.selectedURL = availableURLs.first ?? ""
            }
        } catch {
            DispatchQueue.main.async {
                self.onboardingViewError = .generic(message: error.localizedDescription)
            }
        }
    }

    func createWallet() {
        do {
            try bdkClient.createWallet(words)
            DispatchQueue.main.async {
                self.isOnboarding = false
            }
        } catch let error as CreateWithPersistError {
            DispatchQueue.main.async {
                self.createWithPersistError = error
            }
        } catch {
            DispatchQueue.main.async {
                self.onboardingViewError = .generic(message: error.localizedDescription)
            }
        }
    }

    private func updateWordArray() {
        let trimmedWords = words.trimmingCharacters(in: .whitespacesAndNewlines)
        wordArray = trimmedWords.split(separator: " ").map { String($0) }
    }
}
