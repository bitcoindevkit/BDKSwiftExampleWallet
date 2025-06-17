//
//  BDKClient+.swift
//  BDKSwiftExampleWallet
//
//  Created by Rubens Machion on 31/05/25.
//

extension BDKClient {
    static let kyoto = Self(
        loadWallet: {
            try KyotoService.shared.loadWallet()
        },
        deleteWallet: {
            try KyotoService.shared.deleteWallet()
        },
        createWalletFromSeed: { words in
            try KyotoService.shared.createWallet(params: words)
        },
        createWalletFromDescriptor: { descriptor in
            try KyotoService.shared.createWallet(params: descriptor)
        },
        createWalletFromXPub: { xpub in
            try KyotoService.shared.createWallet(params: xpub)
        },
        getBalance: {
            try KyotoService.shared.getBalance()
        },
        transactions: {
            try KyotoService.shared.getTransactions()
        },
        listUnspent: {
            try KyotoService.shared.listUnspent()
        },
        syncScanWithSyncScanProgress: { progress in
            try await KyotoService.shared.startSync(progress: progress)
        },
        fullScanWithFullScanProgress: { progress in
            try await KyotoService.shared.startFullScan(progress: progress)
        },
        getAddress: {
            try KyotoService.shared.getAddress()
        },
        send: { (address, amount, feeRate) in
            Task {
                try await KyotoService.shared.send(
                    address: address,
                    amount: amount,
                    feeRate: feeRate
                )
            }
        },
        calculateFee: { tx in
            try KyotoService.shared.calculateFee(tx: tx)
        },
        calculateFeeRate: { tx in
            try KyotoService.shared.calculateFeeRate(tx: tx)
        },
        sentAndReceived: { tx in
            try KyotoService.shared.sentAndReceived(tx: tx)
        },
        buildTransaction: { (address, amount, feeRate) in
            try KyotoService.shared.buildTransaction(
                address: address,
                amount: amount,
                feeRate: feeRate
            )
        },
        getBackupInfo: {
            try BDKService.shared.getBackupInfo()
        },
        needsFullScan: {
            BDKService.shared.needsFullScanOfWallet()
        },
        setNeedsFullScan: { value in
            BDKService.shared.setNeedsFullScan(value)
        },
        getNetwork: {
            BDKService.shared.network
        },
        getEsploraURL: {
            BDKService.shared.esploraURL
        },
        updateNetwork: { newNetwork in
            BDKService.shared.updateNetwork(newNetwork)
        },
        updateEsploraURL: { newURL in
            BDKService.shared.updateEsploraURL(newURL)
        },
        stop: {
            try await KyotoService.shared.stopService()
        },
        upateSyncMode: { mode in
            BDKService.shared.updateSyncMode(mode)
        },
        getSyncMode: {
            BDKService.shared.getSyncMode()
        }
    )
}
