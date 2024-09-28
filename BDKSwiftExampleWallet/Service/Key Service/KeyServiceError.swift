//
//  KeyServiceError.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/26/23.
//

import Foundation

enum KeyServiceError: Error {
    case decodingError
    case encodingError
    case readError
    case writeError
    case urlError
}
