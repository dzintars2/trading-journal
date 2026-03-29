import SwiftUI
import SwiftData

@main
struct TradingJournalApp: App {
    
    init() {
        // Trigger a daily backup on each app launch (runs async so it never blocks the UI)
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 2) {
            BackupManager.shared.runDailyBackupIfNeeded()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                // Set the baseline background color
                .preferredColorScheme(.dark)
                .modelContainer(for: [Trade.self, TradingAccount.self])
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            SidebarCommands()
        }
    }
}
