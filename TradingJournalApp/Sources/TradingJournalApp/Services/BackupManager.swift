import Foundation

final class BackupManager {
    
    static let shared = BackupManager()
    private init() {}
    
    private let backupFolderName = "TradingJournal Backups"
    private let dbFileName = "default.store"
    
    // All the SQLite companion files we need to copy alongside the main store
    private let dbCompanionExtensions = [".store-wal", ".store-shm"]
    
    /// Run once on app launch. Copies DB to ~/Documents/TradingJournal Backups/ if no backup exists for today.
    func runDailyBackupIfNeeded() {
        let today = datestamp()
        let backupFolder = backupDirectory()
        let destinationURL = backupFolder.appendingPathComponent("trading_journal_\(today).store")
        
        // Already backed up today — skip
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            print("[BackupManager] Backup already exists for \(today). Skipping.")
            return
        }
        
        // Ensure backup folder exists
        do {
            try FileManager.default.createDirectory(at: backupFolder, withIntermediateDirectories: true)
        } catch {
            print("[BackupManager] Failed to create backup folder: \(error)")
            return
        }
        
        // Copy main .store file
        guard let sourceURL = sourceStoreURL() else {
            print("[BackupManager] SQLite source file not found.")
            return
        }
        
        do {
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            print("[BackupManager] ✅ Backup created: \(destinationURL.lastPathComponent)")
        } catch {
            print("[BackupManager] Failed to copy store: \(error)")
            return
        }
        
        // Copy WAL and SHM companion files if they exist
        for ext in dbCompanionExtensions {
            let companionSource = sourceURL.deletingLastPathComponent()
                .appendingPathComponent(dbFileName + ext.replacingOccurrences(of: ".store", with: ""))
            // Reconstruct: the source is "default.store-wal" etc
            let actualSource = sourceURL.appendingPathExtension(ext.replacingOccurrences(of: ".store", with: ""))
            
            // Correct path: e.g. ~/Library/.../default.store-wal
            let walSource = sourceURL.deletingLastPathComponent()
                .appendingPathComponent("default\(ext)")
            let walDest = backupFolder.appendingPathComponent("trading_journal_\(today)\(ext)")
            
            if FileManager.default.fileExists(atPath: walSource.path) {
                try? FileManager.default.copyItem(at: walSource, to: walDest)
            }
            
            let _ = companionSource // suppress warning
            let _ = actualSource
        }
        
        // Prune old backups — Keep only last 30 days
        pruneOldBackups(in: backupFolder, keepLast: 30)
    }
    
    // MARK: - Private Helpers
    
    private func sourceStoreURL() -> URL? {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        let candidate = appSupport?.appendingPathComponent(dbFileName)
        if let url = candidate, FileManager.default.fileExists(atPath: url.path) {
            return url
        }
        return nil
    }
    
    private func backupDirectory() -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documents.appendingPathComponent(backupFolderName)
    }
    
    private func datestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    private func pruneOldBackups(in folder: URL, keepLast: Int) {
        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: folder,
            includingPropertiesForKeys: [.creationDateKey],
            options: .skipsHiddenFiles
        ) else { return }
        
        // Only consider primary .store backups (no WAL/SHM)
        let storeBackups = contents
            .filter { $0.lastPathComponent.hasSuffix(".store") }
            .sorted { lhs, rhs in
                let lDate = (try? lhs.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? .distantPast
                let rDate = (try? rhs.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? .distantPast
                return lDate > rDate // newest first
            }
        
        if storeBackups.count > keepLast {
            let toDelete = storeBackups.dropFirst(keepLast)
            for url in toDelete {
                try? FileManager.default.removeItem(at: url)
                // Also remove companion files
                for ext in ["-wal", "-shm"] {
                    let companion = url.appendingPathExtension(ext)
                    try? FileManager.default.removeItem(at: companion)
                }
                print("[BackupManager] 🗑 Pruned old backup: \(url.lastPathComponent)")
            }
        }
    }
}
