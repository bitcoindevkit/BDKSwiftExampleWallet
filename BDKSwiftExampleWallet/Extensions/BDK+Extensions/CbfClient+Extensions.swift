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
    private static var logTasks: [ObjectIdentifier: Task<Void, Never>] = [:]
    private static var heartbeatTasks: [ObjectIdentifier: Task<Void, Never>] = [:]
    private static var lastInfoAt: [ObjectIdentifier: Date] = [:]
    private static let monitoringTasksQueue = DispatchQueue(label: "cbf.monitoring.tasks")

    static func createComponents(wallet: Wallet) -> (client: CbfClient, node: CbfNode) {
        do {

            let components = try CbfBuilder()
                .logLevel(logLevel: .debug)
                .scanType(scanType: .sync)
                .dataDir(dataDir: Constants.Config.Kyoto.dbPath)
                .peers(peers: Constants.Networks.Signet.Regular.kyotoPeers)
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
                    case .progress(let progress):
                        await MainActor.run {
                            NotificationCenter.default.post(
                                name: NSNotification.Name("KyotoProgressUpdate"),
                                object: nil,
                                userInfo: ["progress": progress]
                            )
                        }
                    case .newChainHeight(let height):
                        await MainActor.run {
                            NotificationCenter.default.post(
                                name: NSNotification.Name("KyotoChainHeightUpdate"),
                                object: nil,
                                userInfo: ["height": height]
                            )
                            NotificationCenter.default.post(
                                name: NSNotification.Name("KyotoConnectionUpdate"),
                                object: nil,
                                userInfo: ["connected": true]
                            )
                        }
                    case .stateUpdate(let nodeState):
                        await MainActor.run {
                            NotificationCenter.default.post(
                                name: NSNotification.Name("KyotoStateUpdate"),
                                object: nil,
                                userInfo: ["state": nodeState]
                            )
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
                    if case .needConnections = warning {
                        await MainActor.run {
                            NotificationCenter.default.post(
                                name: NSNotification.Name("KyotoConnectionUpdate"),
                                object: nil,
                                userInfo: ["connected": false]
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
            Self.warningTasks[id] = warnings
        }

        // Log listener for detailed debugging
        let logs = Task { [self] in
            while true {
                if Task.isCancelled { break }
                do {
                    let log = try await self.nextLog()
                } catch is CancellationError {
                    break
                } catch {
                    // ignore
                }
            }
        }

        Self.monitoringTasksQueue.sync {
            Self.logTasks[id] = logs
        }
    }

    func stopBackgroundMonitoring() {
        let id = ObjectIdentifier(self)
        Self.monitoringTasksQueue.sync {
            guard let task = Self.monitoringTasks.removeValue(forKey: id) else { return }
            task.cancel()
            if let hb = Self.heartbeatTasks.removeValue(forKey: id) { hb.cancel() }
            if let wt = Self.warningTasks.removeValue(forKey: id) { wt.cancel() }
            if let lt = Self.logTasks.removeValue(forKey: id) { lt.cancel() }
            Self.lastInfoAt.removeValue(forKey: id)
        }
    }

    static func cancelAllMonitoring() {
        Self.monitoringTasksQueue.sync {
            for (_, task) in Self.monitoringTasks { task.cancel() }
            for (_, wt) in Self.warningTasks { wt.cancel() }
            for (_, lt) in Self.logTasks { lt.cancel() }
            for (_, hb) in Self.heartbeatTasks { hb.cancel() }
            Self.monitoringTasks.removeAll()
            Self.warningTasks.removeAll()
            Self.logTasks.removeAll()
            Self.heartbeatTasks.removeAll()
            Self.lastInfoAt.removeAll()
        }
    }
}
