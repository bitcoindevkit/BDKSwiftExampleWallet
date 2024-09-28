//
//  FeeServiceError.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/26/23.
//

import Foundation

enum FeeServiceError: Error {
    case invalidServerResponse
    case invalidURL
    case serialization
}
