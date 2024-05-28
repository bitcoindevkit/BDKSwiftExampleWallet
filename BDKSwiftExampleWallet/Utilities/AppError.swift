//
//  AppError.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 5/9/24.
//

import Foundation

enum AppError: Error, LocalizedError {
    case generic(message: String)

    var description: String? {
        switch self {
        case .generic(let message):
            return message
        }
    }
}
