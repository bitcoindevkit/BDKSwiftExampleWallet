//
//  BDKClient+Esplora.swift
//  BDKSwiftExampleWallet
//
//  Created by Rubens Machion on 31/05/25.
//

extension BDKClient {
    static let esplora = Self(
        loadWallet: {
            try EsploraService.shared.loadWallet()
        },
        deleteWallet: {
            try EsploraService.shared.deleteWallet()
        },
        createWalletFromSeed: { words in
            try EsploraService.shared.createWallet(params: words)
        },
        createWalletFromDescriptor: { descriptor in
            try EsploraService.shared.createWallet(params: descriptor)
        },
        createWalletFromXPub: { xpub in
            try EsploraService.shared.createWallet(params: xpub)
        },
        getBalance: {
            try EsploraService.shared.getBalance()
        },
        transactions: {
            try EsploraService.shared.getTransactions()
        },
        listUnspent: {
            try EsploraService.shared.listUnspent()
        },
        syncScanWithSyncScanProgress: { progress in
            try await EsploraService.shared.startSync(progress: progress)
        },
        fullScanWithFullScanProgress: { progress in
            try await EsploraService.shared.startFullScan(progress: progress)
        },
        getAddress: {
            try EsploraService.shared.getAddress()
        },
        send: { (address, amount, feeRate) in
            Task {
                try await EsploraService.shared.send(address: address, amount: amount, feeRate: feeRate)
            }
        },
        calculateFee: { tx in
            try EsploraService.shared.calculateFee(tx: tx)
        },
        calculateFeeRate: { tx in
            try EsploraService.shared.calculateFeeRate(tx: tx)
        },
        sentAndReceived: { tx in
            try EsploraService.shared.sentAndReceived(tx: tx)
        },
        buildTransaction: { (address, amount, feeRate) in
            try EsploraService.shared.buildTransaction(address: address, amount: amount, feeRate: feeRate)
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
            try await EsploraService.shared.stopService()
        },
        upateSyncMode: { mode in
            BDKService.shared.updateSyncMode(mode)
        },
        getSyncMode: {
            BDKService.shared.getSyncMode()
        }
    )
}
