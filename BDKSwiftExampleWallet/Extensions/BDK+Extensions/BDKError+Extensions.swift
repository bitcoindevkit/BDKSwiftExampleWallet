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
        case .Generic(message: let message):
            return message
        }
    }
}

//extension BdkError {
//    var description: String {
//        switch self {
//        case .InvalidU32Bytes(let message),
//            .Generic(let message),
//            .MissingCachedScripts(let message),
//            .ScriptDoesntHaveAddressForm(let message),
//            .NoRecipients(let message),
//            .NoUtxosSelected(let message),
//            .OutputBelowDustLimit(let message),
//            .InsufficientFunds(let message),
//            .BnBTotalTriesExceeded(let message),
//            .BnBNoExactMatch(let message),
//            .UnknownUtxo(let message),
//            .TransactionNotFound(let message),
//            .TransactionConfirmed(let message),
//            .IrreplaceableTransaction(let message),
//            .FeeRateTooLow(let message),
//            .FeeTooLow(let message),
//            .FeeRateUnavailable(let message),
//            .MissingKeyOrigin(let message),
//            .Key(let message),
//            .ChecksumMismatch(let message),
//            .SpendingPolicyRequired(let message),
//            .InvalidPolicyPathError(let message),
//            .Signer(let message),
//            .InvalidNetwork(let message),
//            .InvalidProgressValue(let message),
//            .ProgressUpdateError(let message),
//            .InvalidOutpoint(let message),
//            .Descriptor(let message),
//            .Encode(let message),
//            .Miniscript(let message),
//            .MiniscriptPsbt(let message),
//            .Bip32(let message),
//            .Secp256k1(let message),
//            .Json(let message),
//            .Hex(let message),
//            .Psbt(let message),
//            .PsbtParse(let message),
//            .Electrum(let message),
//            .Esplora(let message),
//            .Sled(let message),
//            .Rusqlite(let message),
//            .HardenedIndex(let message),
//            .Rpc(let message):
//            return message
//        }
//    }
//}
