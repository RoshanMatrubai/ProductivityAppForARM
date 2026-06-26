import SwiftUI
import SwiftData
import os

private let logger = Logger(subsystem: "com.zenith.app", category: "TaskRowView")

struct TaskRowView: View {
    @Bindable var task: TaskItem
    @AppStorage("isDarkMode") private var isDark: Bool = true
    private var theme: ThemeManager { ThemeManager(isDark: isDark) }
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 18, weight: .light))
                .foregroundStyle(task.isCompleted ? theme.secondaryForeground : theme.foreground)
                .animation(.easeInOut(duration: 0.25), value: task.isCompleted)

            Text(task.title)
                .font(.system(size: 14, weight: .regular, design: .monospaced))
                .strikethrough(task.isCompleted, color: theme.secondaryForeground)
                .foregroundStyle(task.isCompleted ? theme.secondaryForeground : theme.foreground)
                .animation(.easeInOut(duration: 0.25), value: task.isCompleted)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            task.isCompleted.toggle()
            do {
                try modelContext.save()
            } catch {
                logger.error("Failed to save task completion state: \(error.localizedDescription, privacy: .public)")
            }
        }
    }
}

// # MOCK
#Preview {
    let container: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let c = try! ModelContainer(for: TaskItem.self, configurations: config)
        c.mainContext.insert(TaskItem(title: "Write the Phase 4 implementation"))
        c.mainContext.insert(TaskItem(title: "Scaffold the project", isCompleted: true))
        return c
    }()
    TaskRowView(task: TaskItem(title: "Preview task"))
        .padding()
        .background(Color.black)
        .modelContainer(container)
}
