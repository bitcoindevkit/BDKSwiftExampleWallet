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

    var homeViewError: AppError?
    var showingHomeViewErrorAlert = false

    init(bdkClient: BDKClient = .live) {
        self.bdkClient = bdkClient
    }

    func loadWallet() {
        do {
            try bdkClient.loadWallet()
        } catch let error as DescriptorError {
            self.homeViewError = .generic(message: error.localizedDescription)
            self.showingHomeViewErrorAlert = true
        } catch let error as LoadWithPersistError {
            self.homeViewError = .generic(message: error.localizedDescription)
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
