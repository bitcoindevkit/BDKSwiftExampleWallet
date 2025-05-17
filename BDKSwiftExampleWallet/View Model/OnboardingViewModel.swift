//
//  OnboardingViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/6/23.
//

import BitcoinDevKit
import Foundation
import SwiftUI

enum WalletSyncType: Hashable {
    case esplora
    case kyoto
}

// Can't make @Observable yet
// https://developer.apple.com/forums/thread/731187
// Feature or Bug?
class OnboardingViewModel: ObservableObject {
    
    private var bdkSyncService: BDKSyncService

    @AppStorage("isOnboarding") var isOnboarding: Bool?
    
    @Published var walletSyncType: WalletSyncType = .esplora {
        didSet {
            updateWalletSyncType()
        }
    }
    
    @Published var createWithPersistError: CreateWithPersistError?
    var isDescriptor: Bool {
        words.hasPrefix("tr(") || words.hasPrefix("wpkh(") || words.hasPrefix("wsh(")
            || words.hasPrefix("sh(")
    }
    var isXPub: Bool {
        words.hasPrefix("xpub") || words.hasPrefix("tpub") || words.hasPrefix("vpub") || words.hasPrefix("zpub")
    }
    @Published var networkColor = Color.gray
    @Published var onboardingViewError: AppError?
    @Published var selectedNetwork: Network {
        didSet {
            selectedURL = availableURLs.first ?? ""
            bdkSyncService.updateNetwork(network: selectedNetwork)
        }
    }
    @Published var selectedURL: String = "" {
        didSet {
//            bdkClient.updateEsploraURL(selectedURL)
        }
    }
    @Published var words: String = ""
    var wordArray: [String] {
        if words.hasPrefix("xpub") || words.hasPrefix("tpub") || words.hasPrefix("vpub") || words.hasPrefix("zpub") {
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
        bdkSyncService: BDKSyncService
    ) {
        self.bdkSyncService = bdkSyncService
        self.selectedNetwork = bdkSyncService.network
        self.selectedURL = bdkSyncService.network.url
    }

    func createWallet() {
        do {
            try bdkSyncService.deleteWallet()
            try bdkSyncService.createWallet(params: words.isEmpty ? nil : words)
            
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
    
    private func updateWalletSyncType() {
        switch walletSyncType {
        case .esplora:
            bdkSyncService = EsploraServerSyncService(
                network: selectedNetwork
            )
        case .kyoto:
            bdkSyncService = KyotoSyncService(
                network: selectedNetwork
            )
        }
    }
}
