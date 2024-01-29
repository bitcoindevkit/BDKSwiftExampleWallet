//
//  SettingsViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 1/24/24.
//

import BitcoinDevKit
import Foundation
import SwiftUI

class SettingsViewModel: ObservableObject {
    let bdkClient: BDKClient
    let keyClient: KeyClient
    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    @Published var settingsError: BdkError?
    @Published var network: String?
    @Published var esploraURL: String?
    //    @Published var selectedNetwork: Network = .testnet {
    //        didSet {
    //            do {
    //                let networkString = selectedNetwork.description
    //                try KeyClient.live.saveNetwork(networkString)
    //            } catch {
    //                DispatchQueue.main.async {
    //                    self.settingsError = .InvalidNetwork(message: "Error Selecting Network")
    //                }
    //            }
    //        }
    //    }
    //    @Published var selectedNetwork: Network = .testnet {
    //        didSet {
    //            do {
    //                let networkString = selectedNetwork.description
    //                try KeyClient.live.saveNetwork(networkString)
    //                selectedURL = availableURLs.first ?? ""
    //                //try KeyClient.live.saveEsploraURL(selectedURL)
    //            } catch {
    //                DispatchQueue.main.async {
    //                    self.settingsError = .InvalidNetwork(message: "Error Selecting Network")
    //                }
    //            }
    //        }
    //    }
    //    @Published var selectedURL: String = "" {
    //        didSet {
    //            do {
    //                //try KeyClient.live.saveEsploraURL(selectedURL)
    //            } catch {
    //                DispatchQueue.main.async {
    //                    self.settingsError = .Esplora(message: "Error Selecting Esplora")
    //                }
    //            }
    //        }
    //    }

    init(
        bdkClient: BDKClient = .live,
        keyClient: KeyClient = .live
    ) {
        self.bdkClient = bdkClient
        self.keyClient = keyClient
        //        do {
        //            if let networkString = try KeyClient.live.getNetwork() {
        //                self.selectedNetwork = Network(stringValue: networkString) ?? .testnet
        //            } else {
        //                self.selectedNetwork = .testnet
        //            }
        //            if let esploraURL = try KeyClient.live.getEsploraURL() {
        //                self.selectedURL = esploraURL
        //            } else {
        //                self.selectedURL = availableURLs.first ?? ""
        //            }
        //        } catch {
        //            DispatchQueue.main.async {
        //                self.settingsError = .Esplora(message: "Error Selecting Esplora")
        //            }
        //        }

    }

    //    var availableURLs: [String] {
    //        switch selectedNetwork {
    //        case .bitcoin:
    //            return Constants.Config.EsploraServerURLNetwork.Bitcoin.allValues
    //        case .testnet:
    //            return Constants.Config.EsploraServerURLNetwork.Testnet.allValues
    //        case .regtest:
    //            return Constants.Config.EsploraServerURLNetwork.Regtest.allValues
    //        case .signet:
    //            return Constants.Config.EsploraServerURLNetwork.Signet.allValues
    //        }
    //    }

    func delete() {
        do {
            try bdkClient.deleteWallet()
            self.isOnboarding = true
        } catch _ as BdkError {
            DispatchQueue.main.async {
                self.settingsError = BdkError.Generic(message: "Could not delete seed")
            }
        } catch {
            DispatchQueue.main.async {
                self.settingsError = BdkError.Generic(message: "Could not delete seed")
            }
        }
    }

    func getNetwork() {
        do {
            self.network = try keyClient.getNetwork()
        } catch _ as BdkError {
            DispatchQueue.main.async {
                self.settingsError = BdkError.Generic(message: "Could not get network")
            }
        } catch {
            DispatchQueue.main.async {
                self.settingsError = BdkError.Generic(message: "Could not get network")
            }
        }
    }

    func getEsploraUrl() {
        do {
            self.esploraURL = try keyClient.getEsploraURL()
        } catch _ as BdkError {
            DispatchQueue.main.async {
                self.settingsError = BdkError.Generic(message: "Could not get esplora")
            }
        } catch {
            DispatchQueue.main.async {
                self.settingsError = BdkError.Generic(message: "Could not get esplora")
            }
        }
    }
}
