import SwiftUI
import SwiftData
import os

private let logger = Logger(subsystem: "com.zenith.app", category: "TaskRowView")

struct TaskRowView: View {
    @Bindable var task: TaskItem
    let theme: ThemeManager
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        HStack(spacing: 12) {
            // Completion icon
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 18, weight: .light))
                .foregroundStyle(
                    task.isCompleted
                        ? theme.secondaryForeground
                        : theme.foreground
                )
                .animation(.easeInOut(duration: 0.25), value: task.isCompleted)

            // Task title
            Text(task.title)
                .font(.system(size: 14, weight: .regular, design: .monospaced))
                .strikethrough(task.isCompleted, color: theme.secondaryForeground)
                .foregroundStyle(
                    task.isCompleted
                        ? theme.secondaryForeground
                        : theme.foreground
                )
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
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TaskItem.self, configurations: config)

    let sampleTask = TaskItem(title: "Write the Phase 4 implementation")
    sampleTask.isCompleted = false
    container.mainContext.insert(sampleTask)

    let completedTask = TaskItem(title: "Scaffold the project")
    completedTask.isCompleted = true
    container.mainContext.insert(completedTask)

    let theme = ThemeManager()

    return VStack(spacing: 0) {
        TaskRowView(task: sampleTask, theme: theme)
        TaskRowView(task: completedTask, theme: theme)
    }
    .padding()
    .background(theme.background)
    .modelContainer(container)
}
