import BitcoinDevKit
import Foundation

extension Connection {
    static func createConnection() throws -> Connection {
        let documentsDirectoryURL = URL.defaultWalletDirectory
        let walletDataDirectoryURL = documentsDirectoryURL.appendingPathComponent(URL.walletDirectoryName)

        if FileManager.default.fileExists(atPath: walletDataDirectoryURL.path) {
            try FileManager.default.removeItem(at: walletDataDirectoryURL)
        }
        
        try FileManager.default.ensureDirectoryExists(at: walletDataDirectoryURL)
        try FileManager.default.removeOldFlatFileIfNeeded(at: documentsDirectoryURL)
        let connection = try Connection(path: URL.persistenceBackendPath)
        return connection
    }
    
    static func loadConnection() throws -> Connection {
        let persistenceBackendPath = URL.persistenceBackendPath
        let connection = try Connection(path: persistenceBackendPath)
        return connection
    }
}
