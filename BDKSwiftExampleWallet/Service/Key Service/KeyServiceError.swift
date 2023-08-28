//
//  KeyServiceError.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/26/23.
//

import Foundation

enum KeyServiceError: Error {
    case encodingError
    case writeError
    case urlError
    case decodingError
    case readError
}
