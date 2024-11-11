//
//  ReceiveViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/6/23.
//

import BitcoinDevKit
import CoreNFC
import Foundation
import Observation

@Observable
class ReceiveViewModel: NSObject, NFCNDEFReaderSessionDelegate {
    let bdkClient: BDKClient

    private var nfcSession: NFCNDEFReaderSession?

    var address: String = ""
    var receiveViewError: AppError?
    var showingReceiveViewErrorAlert = false

    init(bdkClient: BDKClient = .live) {
        self.bdkClient = bdkClient
    }

    func getAddress() {
        do {
            let address = try bdkClient.getAddress()
            self.address = address
        } catch let error as PersistenceError {
            self.receiveViewError = .generic(message: error.localizedDescription)
            self.showingReceiveViewErrorAlert = true
        } catch {
            self.receiveViewError = .generic(message: error.localizedDescription)
            self.showingReceiveViewErrorAlert = true
        }
    }

}

extension ReceiveViewModel {
    func startNFCSession() {
        guard NFCNDEFReaderSession.readingAvailable else {
            receiveViewError = .generic(message: "NFC not available on this device")
            showingReceiveViewErrorAlert = true
            return
        }

        nfcSession = NFCNDEFReaderSession(
            delegate: self,
            queue: nil,
            invalidateAfterFirstRead: true
        )
        nfcSession?.alertMessage = "Hold your iPhone near the Coldcard Q to verify the address"
        nfcSession?.begin()
    }

    // MARK: - NFCNDEFReaderSessionDelegate

    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        guard let tag = tags.first else { return }

        session.connect(to: tag) { error in
            if let error = error {
                session.invalidate(errorMessage: "Connection error: \(error.localizedDescription)")
                return
            }

            // Send the address to verify
            let ndefMessage = NFCNDEFMessage(records: [
                NFCNDEFPayload(
                    format: .nfcWellKnown,
                    type: "T".data(using: .utf8)!,
                    identifier: Data(),
                    payload: self.address.data(using: .utf8)!
                )
            ])

            tag.writeNDEF(ndefMessage) { error in
                if let error = error {
                    session.invalidate(
                        errorMessage: "Failed to send address: \(error.localizedDescription)"
                    )
                } else {
                    session.alertMessage =
                        "Address sent to Coldcard. Please check the Coldcard screen for verification."
                    session.invalidate()
                }
            }
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        DispatchQueue.main.async {
            self.receiveViewError = .generic(message: error.localizedDescription)
            self.showingReceiveViewErrorAlert = true
        }
    }

    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        // Required delegate method, but no action needed when session becomes active
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        // Check for response from Coldcard
        if let message = messages.first,
            let record = message.records.first,
            let payload = String(data: record.payload, encoding: .utf8)
        {
            // Handle response if Coldcard sends one
            print("Received from Coldcard: \(payload)")
        }
        session.invalidate()
    }

}
