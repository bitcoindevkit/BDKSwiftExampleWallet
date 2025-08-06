//
//  CbfClient+Extensions.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 7/30/25.
//

import BitcoinDevKit
import Foundation

extension CbfClient {
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
        Task {
            var isConnected = false
            while true {
                if let log = try? await self.nextLog() {
                    // Parse specific sync stage messages
                    if log.contains("Attempting to load headers from the database") {
                        await MainActor.run {
                            NotificationCenter.default.post(
                                name: NSNotification.Name("KyotoProgressUpdate"),
                                object: nil,
                                userInfo: ["progress": Float(0.2)]
                            )
                        }
                    }

                    if log.contains("Established an encrypted connection") && !isConnected {
                        isConnected = true
                        await MainActor.run {
                            NotificationCenter.default.post(
                                name: NSNotification.Name("KyotoConnectionUpdate"),
                                object: nil,
                                userInfo: ["connected": true]
                            )
                        }
                    }

                    if log.contains("Need connections") && isConnected {
                        isConnected = false
                        await MainActor.run {
                            NotificationCenter.default.post(
                                name: NSNotification.Name("KyotoConnectionUpdate"),
                                object: nil,
                                userInfo: ["connected": false]
                            )
                        }
                    }
                }

            }
        }

        Task {
            var hasEstablishedConnection = false
            while true {
                if let info = try? await self.nextInfo() {
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
                    case .connectionsMet:
                        await MainActor.run {
                            hasEstablishedConnection = true
                            NotificationCenter.default.post(
                                name: NSNotification.Name("KyotoConnectionUpdate"),
                                object: nil,
                                userInfo: ["connected": true]
                            )
                        }
                    default:
                        break
                    }
                }
            }
        }

        Task {
            while true {
                if let warning = try? await self.nextWarning() {
                    switch warning {
                    case .needConnections:
                        await MainActor.run {
                            NotificationCenter.default.post(
                                name: NSNotification.Name("KyotoConnectionUpdate"),
                                object: nil,
                                userInfo: ["connected": false]
                            )
                        }
                    default:
                        break
                    }
                }
            }
        }
    }
}
