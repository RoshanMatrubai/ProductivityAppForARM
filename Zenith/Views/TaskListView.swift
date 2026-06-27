import SwiftUI
import SwiftData
import os

private let logger = Logger(subsystem: "com.zenith.app", category: "TaskListView")

struct TaskListView: View {
    @Query(sort: \TaskItem.createdAt) private var tasks: [TaskItem]
    @Environment(\.modelContext) private var modelContext
    @AppStorage("selectedTheme") private var selectedTheme: ZenithTheme = .obsidian
    private var theme: ThemeManager { ThemeManager(theme: selectedTheme) }

    @State private var newTaskTitle: String = ""
    @FocusState private var isInputFocused: Bool

    private var remainingCount: Int {
        tasks.filter { !$0.isCompleted }.count
    }

    // Incomplete tasks sorted by dueDate asc (nil last), then createdAt. Completed sink to bottom.
    private var sortedTasks: [TaskItem] {
        let incomplete = tasks.filter { !$0.isCompleted }.sorted { a, b in
            switch (a.dueDate, b.dueDate) {
            case (.some(let da), .some(let db)): return da < db
            case (.some, .none):                 return true
            case (.none, .some):                 return false
            case (.none, .none):                 return a.createdAt < b.createdAt
            }
        }
        let complete = tasks.filter { $0.isCompleted }
        return incomplete + complete
    }

    var body: some View {
        VStack(spacing: 0) {
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

            if tasks.isEmpty {
                Spacer()
                Text("No tasks yet. Add one below.")
                    .font(.system(size: 13, weight: .light, design: .monospaced))
                    .foregroundStyle(theme.secondaryForeground)
                    .multilineTextAlignment(.center)
                Spacer()
            } else {
                List {
                    ForEach(sortedTasks) { task in
                        TaskRowView(task: task)
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
            modelContext.delete(sortedTasks[index])
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
    let container: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let c = try! ModelContainer(for: TaskItem.self, configurations: config)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let tomorrow  = Calendar.current.date(byAdding: .day, value: +1, to: Date())!
        c.mainContext.insert(TaskItem(title: "Finish project plan", isCompleted: true, priority: .medium))
        c.mainContext.insert(TaskItem(title: "Write a task with an extremely long title to verify that multi-line text wrapping works correctly inside the row layout", priority: .low))
        c.mainContext.insert(TaskItem(title: "Review pull request", priority: .high, dueDate: yesterday))
        c.mainContext.insert(TaskItem(title: "Plan sprint", priority: .medium, dueDate: tomorrow))
        return c
    }()
    TaskListView()
        .frame(width: 400, height: 500)
        .modelContainer(container)
}
