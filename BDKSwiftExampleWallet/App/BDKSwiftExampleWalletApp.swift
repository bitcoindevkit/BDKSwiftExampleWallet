//
//  BDKSwiftExampleWalletApp.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 5/22/23.
//

import BitcoinDevKit
import BackgroundTasks
import SwiftUI

@main
struct BDKSwiftExampleWalletApp: App {
    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    @State private var navigationPath = NavigationPath()
    @State private var refreshTrigger = UUID()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        BackgroundCBFSyncTask.register()
        BackgroundCBFSyncTask.schedule()
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigationPath) {
                if !walletExists {
                    OnboardingView(viewModel: .init(bdkClient: .live))
                        .onReceive(NotificationCenter.default.publisher(for: .walletCreated)) { _ in
                            refreshTrigger = UUID()
                        }
                } else {
                    HomeView(viewModel: .init(bdkClient: .live), navigationPath: $navigationPath)
                }
            }
            .onChange(of: isOnboarding) { oldValue, newValue in
                BDKClient.live.setNeedsFullScan(true)
                navigationPath = NavigationPath()
            }
            .onChange(of: scenePhase) { _, newValue in
                if newValue == .background {
                    BackgroundCBFSyncTask.schedule()
                }
            }
        }
    }
}

extension BDKSwiftExampleWalletApp {
    private var walletExists: Bool {
        // Force re-evaluation by reading refreshTrigger and isOnboarding
        let _ = refreshTrigger
        let _ = isOnboarding
        return (try? KeyClient.live.getBackupInfo()) != nil
    }
}

private enum BackgroundCBFSyncTask {
    static let identifier = "com.bitcoindevkit.bdkswiftexamplewallet.cbf-sync"
    private static let minimumInterval: TimeInterval = 60 * 60 * 24 * 7

    private actor TaskCompletionTracker {
        private var didComplete = false

        func complete(task: BGProcessingTask, success: Bool) {
            guard !didComplete else { return }
            didComplete = true
            task.setTaskCompleted(success: success)
        }
    }

    static func register() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: identifier,
            using: nil
        ) { task in
            guard let processingTask = task as? BGProcessingTask else {
                task.setTaskCompleted(success: false)
                return
            }
            handle(processingTask)
        }
    }

    static func schedule() {
        let request = BGProcessingTaskRequest(identifier: identifier)
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = true
        request.earliestBeginDate = Date(timeIntervalSinceNow: minimumInterval)

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("[BackgroundCBF] Failed to schedule task: \(error)")
        }
    }

    private static func handle(_ task: BGProcessingTask) {
        schedule()
        let completionTracker = TaskCompletionTracker()

        let syncTask = Task.detached(priority: .background) {
            do {
                try await runKyotoSync()
                await completionTracker.complete(task: task, success: true)
            } catch {
                print("[BackgroundCBF] Background sync failed: \(error)")
                await completionTracker.complete(task: task, success: false)
            }
        }

        task.expirationHandler = {
            syncTask.cancel()
            Task {
                await completionTracker.complete(task: task, success: false)
            }
        }
    }

    private static func runKyotoSync() async throws {
        let bdkClient = BDKClient.live

        guard (try? bdkClient.getBackupInfo()) != nil else {
            return
        }

        try bdkClient.loadWallet()

        guard bdkClient.getClientType() == .kyoto else {
            return
        }

        let inspector = WalletSyncScriptInspector(updateProgress: { _, _ in })
        try await bdkClient.syncWithInspector(inspector)
    }
}
