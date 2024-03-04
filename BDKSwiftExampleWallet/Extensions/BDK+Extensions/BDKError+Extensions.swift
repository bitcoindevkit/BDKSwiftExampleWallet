//
//  BDKError+Extensions.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 9/5/23.
//

import BitcoinDevKit
import Foundation

extension Alpha3Error {
    var description: String {
        switch self {
        case .Generic(let message):
            return message
        }
    }
}

extension CalculateFeeError {
    var description: String {
        switch self {
        case .MissingTxOut(let outPoints):
            return outPoints.description
        case .NegativeFee(let fee):
            return fee.description
        }
    }
}

extension EsploraError {
    var description: String {
        switch self {
        case .Ureq(let errorMessage),
            .UreqTransport(let errorMessage),
            .Io(let errorMessage),
            .Parsing(let errorMessage),
            .BitcoinEncoding(let errorMessage),
            .Hex(let errorMessage):
            return errorMessage

        case .Http(let statusCode):
            return statusCode.description

        case .HeaderHeightNotFound(let height):
            return height.description

        case .NoHeader:
            return "No header found."

        case .TransactionNotFound:
            return "Transaction not found."

        case .HeaderHashNotFound:
            return "Header hash not found."
        }
    }
}

extension WalletCreationError {
    var description: String {
        switch self {
        case .Io(let e):
            return e.description
        case .InvalidMagicBytes(let got, let expected):
            return "got: \(got), expected \(expected) "
        case .Descriptor:
            return "descriptor"
        case .Write:
            return "write"
        case .Load:
            return "load"
        case .NotInitialized:
            return "not initialized"
        case .LoadedGenesisDoesNotMatch:
            return "loaded genesis does not match"
        case .LoadedNetworkDoesNotMatch(let expected, let got):
            return "got: \(String(describing: got)), expected \(expected)"
        }
    }
}
