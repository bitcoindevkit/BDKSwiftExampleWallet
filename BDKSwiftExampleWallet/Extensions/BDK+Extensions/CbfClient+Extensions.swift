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
            Task {
                do {
                    try await components.node.run()
                } catch {
                    // Kyoto: Failed to start node
                }
            }

            components.client.startBackgroundMonitoring()

            return (client: components.client, node: components.node)
        } catch {
            fatalError("Failed to create CBF components: \(error)")
        }
    }

    func startBackgroundMonitoring() {

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
