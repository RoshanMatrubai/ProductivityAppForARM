import SwiftUI
import SwiftData
import os

private let logger = Logger(subsystem: "com.zenith.app", category: "persistence")

@main
struct ZenithApp: App {
    private let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: TaskItem.self)
        } catch {
            // Schema migration failure (e.g. adding columns to an existing store).
            // Wipe the store and recreate — acceptable trade-off during dev schema evolution.
            logger.error("SwiftData init failed, wiping store and retrying: \(error, privacy: .public)")
            ZenithApp.nukeDefaultStore()
            do {
                container = try ModelContainer(for: TaskItem.self)
            } catch {
                fatalError("Cannot create ModelContainer after store reset: \(error)")
            }
        }
    }

    private static func nukeDefaultStore() {
        let fm = FileManager.default
        guard let appSupport = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else { return }
        let storeURL = appSupport.appendingPathComponent("default.store")
        if fm.fileExists(atPath: storeURL.path) {
            try? fm.removeItem(at: storeURL)
            logger.info("Wiped SwiftData store at \(storeURL.path, privacy: .public)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 700, minHeight: 500)
        }
        .modelContainer(container)
        .defaultSize(width: 800, height: 580)
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }
}
