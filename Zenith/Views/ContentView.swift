import SwiftUI
import SwiftData
import AppKit

struct ContentView: View {
    @AppStorage("selectedTheme") private var selectedTheme: ZenithTheme = .obsidian
    private var theme: ThemeManager { ThemeManager(theme: selectedTheme) }

    @State private var timer = TimerViewModel()

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
                .background(theme.foreground.opacity(0.15))
            HStack(spacing: 0) {
                PomodoroView(timer: timer)
                    .frame(width: 340)
                Divider()
                    .background(theme.foreground.opacity(0.15))
                TaskListView()
                    .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.background.ignoresSafeArea())
        .animation(.easeInOut(duration: 0.2), value: selectedTheme)
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { _ in
            timer.saveState()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWorkspace.willSleepNotification)) { _ in
            timer.saveState()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.willResignActiveNotification)) { _ in
            timer.saveState()
        }
    }

    private var header: some View {
        HStack {
            Text("ZENITH")
                .font(.system(size: 13, weight: .black, design: .monospaced))
                .tracking(6)
                .foregroundStyle(theme.foreground)
            Spacer()
            HStack(spacing: 6) {
                ForEach(ZenithTheme.allCases, id: \.self) { t in
                    Circle()
                        .fill(t.background)
                        .frame(width: 14, height: 14)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    t.foreground.opacity(selectedTheme == t ? 1.0 : 0.45),
                                    lineWidth: selectedTheme == t ? 2 : 1
                                )
                        )
                        .scaleEffect(selectedTheme == t ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.15), value: selectedTheme)
                        .onTapGesture { selectedTheme = t }
                }
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 16)
    }
}

// # MOCK
#Preview {
    let container: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let c = try! ModelContainer(for: TaskItem.self, configurations: config)
        c.mainContext.insert(TaskItem(title: "Finish project plan", isCompleted: true))
        c.mainContext.insert(TaskItem(title: "Write a task with an extremely long title to verify that multi-line text wrapping works correctly inside the row layout"))
        c.mainContext.insert(TaskItem(title: "Review pull request"))
        return c
    }()
    ContentView()
        .frame(width: 800, height: 580)
        .modelContainer(container)
}
