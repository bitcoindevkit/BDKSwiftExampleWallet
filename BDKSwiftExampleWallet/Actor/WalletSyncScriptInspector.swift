//
//  WalletSyncScriptInspector.swift
//  BDKSwiftExampleWallet
//
//  Created by Rubens Machion on 23/04/25.
//

import BitcoinDevKit
import Foundation

actor WalletSyncScriptInspector: @preconcurrency SyncScriptInspector {
    private let updateProgress: @Sendable (UInt64, UInt64) -> Void
    private var inspectedCount: UInt64 = 0
    private var totalCount: UInt64 = 0

    init(updateProgress: @escaping @Sendable (UInt64, UInt64) -> Void) {
        self.updateProgress = updateProgress
    }

    func inspect(script: Script, total: UInt64) {
        totalCount = total
        inspectedCount += 1

        let delay: TimeInterval =
            if total <= 5 {
                0.2
            } else if total < 10 {
                0.15
            } else if total < 20 {
                0.1
            } else {
                0
            }
        Thread.sleep(forTimeInterval: delay)
        updateProgress(inspectedCount, totalCount)
    }
}
