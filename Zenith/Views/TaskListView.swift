import SwiftUI
import SwiftData
import os

private let logger = Logger(subsystem: "com.zenith.app", category: "TaskListView")

struct TaskListView: View {
    @Query(sort: \TaskItem.createdAt) private var tasks: [TaskItem]
    @Environment(\.modelContext) private var modelContext
    let theme: ThemeManager

    @State private var newTaskTitle: String = ""
    @FocusState private var isInputFocused: Bool

    private var remainingCount: Int {
        tasks.filter { !$0.isCompleted }.count
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("TASKS")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .tracking(2)
                    .foregroundStyle(theme.secondaryForeground)

                Spacer()

                Text("\(remainingCount) remaining")
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                    .foregroundStyle(theme.secondaryForeground)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            Divider()
                .background(theme.secondaryForeground.opacity(0.3))

            // Task list or empty state
            if tasks.isEmpty {
                Spacer()
                Text("No tasks yet. Add one below.")
                    .font(.system(size: 13, weight: .light, design: .monospaced))
                    .foregroundStyle(theme.secondaryForeground)
                    .multilineTextAlignment(.center)
                Spacer()
            } else {
                List {
                    ForEach(tasks) { task in
                        TaskRowView(task: task, theme: theme)
                            .listRowBackground(theme.background)
                            .listRowSeparatorTint(theme.secondaryForeground.opacity(0.3))
                    }
                    .onDelete(perform: deleteTasks)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(theme.background)
            }

            Divider()
                .background(theme.secondaryForeground.opacity(0.3))

            // Input row
            HStack(spacing: 10) {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(theme.secondaryForeground)

                TextField("Add a task…", text: $newTaskTitle)
                    .font(.system(size: 14, weight: .regular, design: .monospaced))
                    .foregroundStyle(theme.foreground)
                    .textFieldStyle(.plain)
                    .focused($isInputFocused)
                    .onSubmit { addTask() }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(theme.background)
    }

    // MARK: - Mutations

    private func addTask() {
        let trimmed = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let item = TaskItem(title: trimmed)
        modelContext.insert(item)

        do {
            try modelContext.save()
        } catch {
            logger.error("Failed to save new task: \(error.localizedDescription, privacy: .public)")
        }

        newTaskTitle = ""
        isInputFocused = true
    }

    private func deleteTasks(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(tasks[index])
        }

        do {
            try modelContext.save()
        } catch {
            logger.error("Failed to save after deleting tasks: \(error.localizedDescription, privacy: .public)")
        }
    }
}

// # MOCK
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TaskItem.self, configurations: config)

    // Seed mock tasks
    let t1 = TaskItem(title: "Finish project plan")
    t1.isCompleted = true
    container.mainContext.insert(t1)

    let t2 = TaskItem(
        title: "Write a task with an extremely long title to verify that multi-line text wrapping works correctly inside the row layout"
    )
    t2.isCompleted = false
    container.mainContext.insert(t2)

    let t3 = TaskItem(title: "Review pull request")
    t3.isCompleted = false
    container.mainContext.insert(t3)

    let theme = ThemeManager()

    return TaskListView(theme: theme)
        .frame(width: 400, height: 500)
        .modelContainer(container)
}
