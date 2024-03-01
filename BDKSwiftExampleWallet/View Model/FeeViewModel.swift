//
//  FeeViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 9/22/23.
//

import BitcoinDevKit
import Foundation
//
//@MainActor
//@Observable
//class FeeViewModel {
//    let feeClient: FeeClient
//    let bdkClient: BDKClient
//
//    var txBuilderResult: TxBuilderResult?
//    var recommendedFees: RecommendedFees?
//    var feeViewError: Alpha3Error?//BdkError?
//    var showingFeeViewErrorAlert = false
//    var selectedFeeIndex: Int = 2
//    var selectedFee: Int? {
//        guard let fees = recommendedFees else {
//            return nil
//        }
//        switch selectedFeeIndex {
//        case 0: return fees.minimumFee
//        case 1: return fees.hourFee
//        case 2: return fees.halfHourFee
//        default: return fees.fastestFee
//        }
//    }
//    var selectedFeeDescription: String {
//        guard let selectedFee = selectedFee else {
//            return "Failed to load fees"
//        }
//        let feeText = text(for: selectedFeeIndex)
//        return "Selected \(feeText) Fee: \(selectedFee) sats"
//    }
//
//    init(feeClient: FeeClient = .live, bdkClient: BDKClient = .live) {
//        self.feeClient = feeClient
//        self.bdkClient = bdkClient
//    }
//
//    func getFees() async {
//        do {
//            let recommendedFees = try await feeClient.fetchFees()
//            self.recommendedFees = recommendedFees
//        } catch {
//            self.feeViewError = .Generic(message: "Error Getting Fees")
//            self.showingFeeViewErrorAlert = true
//        }
//    }
//
//    private func text(for index: Int) -> String {
//        switch index {
//        case 0:
//            return "No Priority"
//        case 1:
//            return "Low Priority"
//        case 2:
//            return "Medium Priority"
//        case 3:
//            return "High Priority"
//        default:
//            return ""
//        }
//    }
//
//}
