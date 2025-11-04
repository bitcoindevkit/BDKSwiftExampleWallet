//
//  CbfClient+Extensions.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 7/30/25.
//

import BitcoinDevKit
import Foundation

extension CbfClient {
    // Track monitoring tasks per client for clean cancellation
    private static var monitoringTasks: [ObjectIdentifier: Task<Void, Never>] = [:]
    private static var warningTasks: [ObjectIdentifier: Task<Void, Never>] = [:]
    private static var heartbeatTasks: [ObjectIdentifier: Task<Void, Never>] = [:]
    private static var lastInfoAt: [ObjectIdentifier: Date] = [:]
    private static let monitoringTasksQueue = DispatchQueue(label: "cbf.monitoring.tasks")

    static func createComponents(
        wallet: Wallet,
        scanType: ScanType,
        peers: [Peer]
    ) -> (client: CbfClient, node: CbfNode) {
        do {
            let network = wallet.network()
            let dataDir = Constants.Config.Kyoto.dbPath
            print(
                "[Kyoto] Preparing CBF components – network: \(network), dataDir: \(dataDir), peers: \(peers.count), scanType: \(scanType)"
            )

            let components = try CbfBuilder()
                .scanType(scanType: scanType)
                .dataDir(dataDir: dataDir)
                .peers(peers: peers)
                .build(wallet: wallet)

            components.node.run()

            components.client.startBackgroundMonitoring()

            return (client: components.client, node: components.node)
        } catch {
            fatalError("Failed to create CBF components: \(error)")
        }
    }

    func startBackgroundMonitoring() {
        let id = ObjectIdentifier(self)

        let task = Task { [self] in
            while true {
                if Task.isCancelled { break }
                do {
                    let info = try await self.nextInfo()
                    CbfClient.monitoringTasksQueue.sync { Self.lastInfoAt[id] = Date() }
                    switch info {
                    case .progress(let chainHeight, let filtersDownloadedPercent):
                        await MainActor.run {
                            NotificationCenter.default.post(
                                name: NSNotification.Name("KyotoProgressUpdate"),
                                object: nil,
                                userInfo: [
                                    "progress": filtersDownloadedPercent,
                                    "height": Int(chainHeight),
                                ]
                            )
                            NotificationCenter.default.post(
                                name: NSNotification.Name("KyotoChainHeightUpdate"),
                                object: nil,
                                userInfo: ["height": Int(chainHeight)]
                            )
                            NotificationCenter.default.post(
                                name: NSNotification.Name("KyotoConnectionUpdate"),
                                object: nil,
                                userInfo: ["connected": true]
                            )
                        }
                    case .blockReceived(_):
                        await MainActor.run {
                            NotificationCenter.default.post(
                                name: NSNotification.Name("KyotoConnectionUpdate"),
                                object: nil,
                                userInfo: ["connected": true]
                            )
                        }
                    case .connectionsMet, .successfulHandshake:
                        await MainActor.run {
                            NotificationCenter.default.post(
                                name: NSNotification.Name("KyotoConnectionUpdate"),
                                object: nil,
                                userInfo: ["connected": true]
                            )
                        }
                    }
                } catch is CancellationError {
                    break
                } catch {
                    // ignore
                }
            }
        }

        Self.monitoringTasksQueue.sync {
            Self.monitoringTasks[id] = task
            Self.lastInfoAt[id] = Date()
        }

        // Heartbeat task to signal idleness while awaiting Info events
        let heartbeat = Task {
            while true {
                if Task.isCancelled { break }
                try? await Task.sleep(nanoseconds: 5_000_000_000)
                if Task.isCancelled { break }
                var idleFor: TimeInterval = 0
                CbfClient.monitoringTasksQueue.sync {
                    if let last = Self.lastInfoAt[id] { idleFor = Date().timeIntervalSince(last) }
                }
            }
        }

        Self.monitoringTasksQueue.sync {
            Self.heartbeatTasks[id] = heartbeat
        }

        // Minimal warnings listener for visibility while syncing
        let warnings = Task { [self] in
            while true {
                if Task.isCancelled { break }
                do {
                    let warning = try await self.nextWarning()
                    switch warning {
                    case .needConnections:
                        await MainActor.run {
                            NotificationCenter.default.post(
                                name: NSNotification.Name("KyotoConnectionUpdate"),
                                object: nil,
                                userInfo: ["connected": false]
                            )
                        }
                    case let .transactionRejected(wtxid, reason):
                        BDKService.shared.handleKyotoRejectedTransaction(wtxidHex: wtxid)
                        if let reason {
                            print("Kyoto rejected tx \(wtxid): \(reason)")
                        } else {
                            print("Kyoto rejected tx \(wtxid)")
                        }
                    default:
                        break
                    }
                } catch is CancellationError {
                    break
                } catch {
                    // ignore
                }
            }
        }

        Self.monitoringTasksQueue.sync {
            Self.warningTasks[id] = warnings
        }

    }

    func stopBackgroundMonitoring() {
        let id = ObjectIdentifier(self)
        Self.monitoringTasksQueue.sync {
            guard let task = Self.monitoringTasks.removeValue(forKey: id) else { return }
            task.cancel()
            if let hb = Self.heartbeatTasks.removeValue(forKey: id) { hb.cancel() }
            if let wt = Self.warningTasks.removeValue(forKey: id) { wt.cancel() }
            Self.lastInfoAt.removeValue(forKey: id)
        }
    }

    static func cancelAllMonitoring() {
        Self.monitoringTasksQueue.sync {
            for (_, task) in Self.monitoringTasks { task.cancel() }
            for (_, wt) in Self.warningTasks { wt.cancel() }
            for (_, hb) in Self.heartbeatTasks { hb.cancel() }
            Self.monitoringTasks.removeAll()
            Self.warningTasks.removeAll()
            Self.heartbeatTasks.removeAll()
            Self.lastInfoAt.removeAll()
        }
    }
}
