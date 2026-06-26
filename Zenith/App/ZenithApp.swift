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
            logger.error("SwiftData ModelContainer failed to initialize: \(error, privacy: .public)")
            fatalError("Cannot create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 700, minHeight: 500)
        }
        .modelContainer(container)
        .windowResizability(.contentSize)
        .defaultSize(width: 800, height: 580)
        .commands {
            // Remove File > New Window — single-window app
            CommandGroup(replacing: .newItem) {}
        }
    }
}
