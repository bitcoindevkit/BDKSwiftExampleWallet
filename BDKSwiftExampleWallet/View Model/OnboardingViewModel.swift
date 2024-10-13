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
    @Published var networkColor = Color.gray
    @Published var onboardingViewError: AppError?
    // @Published var selectedNetwork: Network = .signet {
    //     didSet {
    //         do {
    //             let networkString = selectedNetwork.description
    //             try keyClient.saveNetwork(networkString)
    //             selectedURL = availableURLs.first ?? ""
    //             try keyClient.saveEsploraURL(selectedURL)
    //         } catch {
    //             DispatchQueue.main.async {
    //                 self.onboardingViewError = .generic(message: error.localizedDescription)
    //             }
    //         }
    //     }
    // }
    // @Published var selectedURL: String = "" {
    //     didSet {
    //         do {
    //             try keyClient.saveEsploraURL(selectedURL)
    //         } catch {
    //             DispatchQueue.main.async {
    //                 self.onboardingViewError = .generic(message: error.localizedDescription)
    //             }
    //         }
    //     }
    // }
    @Published var selectedNetwork: Network = .signet {
        didSet {
            print("OnboardingViewModel: Network changed from \(oldValue) to \(selectedNetwork)")
            bdkClient.updateNetwork(selectedNetwork)
            selectedURL = availableURLs.first ?? ""
            bdkClient.updateEsploraURL(selectedURL)
        }
    }
    @Published var selectedURL: String = "" {
        didSet {
            print("OnboardingViewModel: Esplora URL changed from \(oldValue) to \(selectedURL)")
            bdkClient.updateEsploraURL(selectedURL)
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
    //    private func availableURLs(for network: Network) -> [String] {
    //        switch network {
    //        case .signet:
    //            return Constants.Config.EsploraServerURLNetwork.Signet.allValues
    //        case .testnet:
    //            return Constants.Config.EsploraServerURLNetwork.Testnet.allValues
    //        case .bitcoin:
    //            return Constants.Config.EsploraServerURLNetwork.Bitcoin.allValues
    //        case .regtest:
    //            return Constants.Config.EsploraServerURLNetwork.Regtest.allValues
    //        }
    //    }
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

    //    init(
    //        bdkClient: BDKClient = .live,
    //        keyClient: KeyClient = .live
    //    ) {
    //        self.bdkClient = bdkClient
    //        self.keyClient = keyClient
    //        print("OnboardingViewModel: Initializing")
    //
    //        let currentNetwork = bdkClient.getNetwork()
    //        let currentURL = bdkClient.getEsploraURL()
    //
    //        // Set network
    //        if let storedNetwork = try? keyClient.getNetwork().flatMap({ Network(stringValue: $0) }) {
    //            self.selectedNetwork = storedNetwork
    //            if storedNetwork != currentNetwork {
    //                print("OnboardingViewModel: Network changed from \(currentNetwork) to \(storedNetwork)")
    //                bdkClient.updateNetwork(storedNetwork)
    //            } else {
    //                print("OnboardingViewModel: Network unchanged: \(currentNetwork)")
    //            }
    //        } else {
    //            self.selectedNetwork = currentNetwork
    //            print("OnboardingViewModel: Using current network: \(currentNetwork)")
    //        }
    //
    //        // Set Esplora URL
    //        if let storedURL = try? keyClient.getEsploraURL(), isValidURL(storedURL, for: self.selectedNetwork) {
    //            self.selectedURL = storedURL
    //        } else if isValidURL(currentURL, for: self.selectedNetwork) {
    //            self.selectedURL = currentURL
    //        } else {
    //            self.selectedURL = availableURLs(for: self.selectedNetwork).first ?? ""
    //        }
    //
    //        if self.selectedURL != currentURL {
    //            print("OnboardingViewModel: Esplora URL changed from \(currentURL) to \(self.selectedURL)")
    //            bdkClient.updateEsploraURL(self.selectedURL)
    //        } else {
    //            print("OnboardingViewModel: Esplora URL unchanged: \(self.selectedURL)")
    //        }
    //
    //        print("OnboardingViewModel: Initialized with network \(self.selectedNetwork) and URL \(self.selectedURL)")
    //    }

    //    init(
    //        bdkClient: BDKClient = .live,
    //        keyClient: KeyClient = .live
    //    ) {
    //        self.bdkClient = bdkClient
    //        self.keyClient = keyClient
    //        print("OnboardingViewModel: Initializing")
    //
    //        let currentNetwork = bdkClient.getNetwork()
    //        let currentURL = bdkClient.getEsploraURL()
    //
    //        // Set network
    //        if let storedNetwork = try? keyClient.getNetwork().flatMap({ Network(stringValue: $0) }) {
    //            self.selectedNetwork = storedNetwork
    //            if storedNetwork != currentNetwork {
    //                print(
    //                    "OnboardingViewModel: Network changed from \(currentNetwork) to \(storedNetwork)"
    //                )
    //                bdkClient.updateNetwork(storedNetwork)
    //            } else {
    //                print("OnboardingViewModel: Network unchanged: \(currentNetwork)")
    //            }
    //        } else {
    //            self.selectedNetwork = currentNetwork
    //            print("OnboardingViewModel: Using current network: \(currentNetwork)")
    //        }
    //
    //        // Set Esplora URL
    //        if let storedURL = try? keyClient.getEsploraURL(),
    //            isValidURL(storedURL, for: self.selectedNetwork)
    //        {
    //            self.selectedURL = storedURL
    //        } else if isValidURL(currentURL, for: self.selectedNetwork) {
    //            self.selectedURL = currentURL
    //        } else {
    //            self.selectedURL = availableURLs(for: self.selectedNetwork).first ?? ""
    //        }
    //
    //        if self.selectedURL != currentURL {
    //            print(
    //                "OnboardingViewModel: Esplora URL changed from \(currentURL) to \(self.selectedURL)"
    //            )
    //            bdkClient.updateEsploraURL(self.selectedURL)
    //        } else {
    //            print("OnboardingViewModel: Esplora URL unchanged: \(self.selectedURL)")
    //        }
    //
    //        print(
    //            "OnboardingViewModel: Initialized with network \(self.selectedNetwork) and URL \(self.selectedURL)"
    //        )
    //    }

    init(
        bdkClient: BDKClient = .live
    ) {
        self.bdkClient = bdkClient
        print("OnboardingViewModel: Initializing")

        let currentNetwork = bdkClient.getNetwork()
        let currentURL = bdkClient.getEsploraURL()

        self.selectedNetwork = currentNetwork
        self.selectedURL = currentURL

        print(
            "OnboardingViewModel: Initialized with network \(self.selectedNetwork) and URL \(self.selectedURL)"
        )
    }

    //    private func isValidURL(_ url: String, for network: Network) -> Bool {
    //        switch network {
    //        case .signet:
    //            return Constants.Config.EsploraServerURLNetwork.Signet.allValues.contains(url)
    //        case .testnet:
    //            return Constants.Config.EsploraServerURLNetwork.Testnet.allValues.contains(url)
    //        case .bitcoin:
    //            return Constants.Config.EsploraServerURLNetwork.Bitcoin.allValues.contains(url)
    //        case .regtest:
    //            return Constants.Config.EsploraServerURLNetwork.Regtest.allValues.contains(url)
    //        }
    //    }

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
