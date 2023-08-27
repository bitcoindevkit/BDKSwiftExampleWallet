//
//  SendViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/6/23.
//

import Foundation
import BitcoinDevKit
import Observation

@MainActor
@Observable
class SendViewModel {
    let feeService: FeeAPIService//FeeService
    var balanceTotal: UInt64 = 0
    var recommendedFees: RecommendedFees?
    var selectedFeeIndex: Int = 2
    var selectedFee: Int? {
        guard let fees = recommendedFees else {
            return nil
        }
        switch selectedFeeIndex {
        case 0: return fees.minimumFee
        case 1: return fees.hourFee
        case 2: return fees.halfHourFee
        default: return fees.fastestFee
        }
    }
    
    var selectedFeeDescription: String {
        guard let selectedFee = selectedFee else {
            return "Failed to load fees"
        }
        
        let feeText = text(for: selectedFeeIndex)
        return "Selected \(feeText) Fee: \(selectedFee) sats"
    }
    
    private func text(for index: Int) -> String {
        
        switch index {
            
        //"Minimum Fee"
        case 0:
            return "No Priority"
            
        //"Hour Fee"
        case 1:
            return "Low Priority"
            
        //"Half Hour Fee"
        case 2:
            return "Medium Priority"
            
        //"Fastest Fee"
        case 3:
            return "High Priority"
            
        default:
            return ""
            
        }
        
    }
    let bdkService: BDKServiceAPI

    init(feeService: FeeAPIService = .live, bdkService: BDKServiceAPI = .live) {
        self.feeService = feeService
        self.bdkService = bdkService
    }
    
    func getBalance() {
        do {
            let balance = try bdkService.getBalance()
            self.balanceTotal = balance.total
        } catch let error as WalletError {
            print("getBalance - Wallet Error: \(error.localizedDescription)")
        } catch {
            print("getBalance - Undefined Error: \(error.localizedDescription)")
        }
    }
    
    func send(address: String, amount: UInt64, feeRate: Float?) {
        do {
            try bdkService.send(address, amount, feeRate)
        } catch let error as WalletError {
            print("send - Wallet Error: \(error.localizedDescription)")
        } catch {
            print("send - Undefined Error: \(error.localizedDescription)")
        }
    }
    
    func getFees() async {
        do {
            let recommendedFees = try await feeService.fetchFees()
            self.recommendedFees = recommendedFees
        } catch {
            print("getFees error: \(error.localizedDescription)")
        }
    }
    
}
