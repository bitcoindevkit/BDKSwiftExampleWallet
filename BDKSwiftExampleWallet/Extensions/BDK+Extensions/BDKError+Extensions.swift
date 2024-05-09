//
//  BDKError+Extensions.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 9/5/23.
//

import BitcoinDevKit
import Foundation

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
        case .HeaderHeightNotFound(let height):
            return height.description
        case .TransactionNotFound:
            return "Transaction not found."
        case .HeaderHashNotFound:
            return "Header hash not found."
        case .Minreq(let errorMessage):
            return errorMessage
        case .HttpResponse(let status, let errorMessage):
            return "\(status): \(errorMessage)"
        case .Parsing(let errorMessage):
            return errorMessage
        case .StatusCode(let errorMessage):
            return errorMessage
        case .BitcoinEncoding(let errorMessage):
            return errorMessage
        case .HexToArray(let errorMessage):
            return errorMessage
        case .HexToBytes(let errorMessage):
            return errorMessage
        case .InvalidHttpHeaderName(let name):
            return name
        case .InvalidHttpHeaderValue(let value):
            return value
        case .RequestAlreadyConsumed:
            return "Request Already Consumed."
        }
    }
}

extension WalletCreationError {
    var description: String {
        switch self {
        case .Io(let e):
            return e.description
        case .InvalidMagicBytes(let got, let expected):
            return "got: \(got), expected \(expected)"
        case .Descriptor:
            return "descriptor"
        case .NotInitialized:
            return "not initialized"
        case .LoadedGenesisDoesNotMatch:
            return "loaded genesis does not match"
        case .LoadedNetworkDoesNotMatch(let expected, let got):
            return "got: \(String(describing: got)), expected \(expected)"
        case .Persist(let errorMessage):
            return errorMessage
        }
    }
}
