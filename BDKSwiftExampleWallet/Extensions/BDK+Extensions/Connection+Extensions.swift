import BitcoinDevKit
import Foundation

extension Connection {
    static func createConnection() throws -> Connection {
        let documentsDirectoryURL = URL.defaultWalletDirectory
        let walletDataDirectoryURL = documentsDirectoryURL.appendingPathComponent(URL.walletDirectoryName)

        try FileManager.default.ensureDirectoryExists(at: walletDataDirectoryURL)
        try FileManager.default.removeOldFlatFileIfNeeded(at: documentsDirectoryURL)
        let connection = try Connection(path: URL.persistenceBackendPath)
        return connection
    }
}
