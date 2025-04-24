//
//  WalletFullScanScriptInspector.swift
//  BDKSwiftExampleWallet
//
//  Created by Rubens Machion on 23/04/25.
//

import BitcoinDevKit

actor WalletFullScanScriptInspector: @preconcurrency FullScanScriptInspector {
    private let updateProgress: @Sendable (UInt64) -> Void
    private var inspectedCount: UInt64 = 0

    init(updateProgress: @escaping @Sendable (UInt64) -> Void) {
        self.updateProgress = updateProgress
    }

    func inspect(keychain: KeychainKind, index: UInt32, script: Script) {
        inspectedCount += 1
        updateProgress(inspectedCount)
    }
}
