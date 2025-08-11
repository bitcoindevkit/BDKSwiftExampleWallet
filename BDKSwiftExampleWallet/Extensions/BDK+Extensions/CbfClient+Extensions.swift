//
//  CbfClient+Extensions.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 7/30/25.
//

import BitcoinDevKit
import Foundation

extension CbfClient {
    // Track one monitoring task per client for clean cancellation
    private static var monitoringTasks: [ObjectIdentifier: Task<Void, Never>] = [:]
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
            var hasEstablishedConnection = false
            while true {
                if Task.isCancelled { break }
                do {
                    let info = try await self.nextInfo()
                    switch info {
                    case let .progress(progress):
                        await MainActor.run {
                            NotificationCenter.default.post(
                                name: NSNotification.Name("KyotoProgressUpdate"),
                                object: nil,
                                userInfo: ["progress": progress]
                            )
                        }
                    case let .newChainHeight(height):
                        await MainActor.run {
                            NotificationCenter.default.post(
                                name: NSNotification.Name("KyotoChainHeightUpdate"),
                                object: nil,
                                userInfo: ["height": height]
                            )
                            if !hasEstablishedConnection {
                                hasEstablishedConnection = true
                                NotificationCenter.default.post(
                                    name: NSNotification.Name("KyotoConnectionUpdate"),
                                    object: nil,
                                    userInfo: ["connected": true]
                                )
                            }
                        }
                    case .connectionsMet, .successfulHandshake:
                        await MainActor.run {
                            if !hasEstablishedConnection {
                                hasEstablishedConnection = true
                                NotificationCenter.default.post(
                                    name: NSNotification.Name("KyotoConnectionUpdate"),
                                    object: nil,
                                    userInfo: ["connected": true]
                                )
                            }
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
        }
    }

    func stopBackgroundMonitoring() {
        let id = ObjectIdentifier(self)
        Self.monitoringTasksQueue.sync {
            guard let task = Self.monitoringTasks.removeValue(forKey: id) else { return }
            task.cancel()
        }
    }

    static func cancelAllMonitoring() {
        Self.monitoringTasksQueue.sync {
            for (_, task) in Self.monitoringTasks { task.cancel() }
            Self.monitoringTasks.removeAll()
        }
    }
}
