import SwiftUI
import SwiftData
import os

private let logger = Logger(subsystem: "com.zenith.app", category: "TaskRowView")

private let dueDateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "MMM d"
    return f
}()

private extension TaskPriority {
    var color: Color {
        switch self {
        case .low:    Color(red: 0.13, green: 0.77, blue: 0.37)  // green
        case .medium: Color(red: 0.98, green: 0.45, blue: 0.09)  // orange
        case .high:   Color(red: 0.94, green: 0.27, blue: 0.27)  // red
        }
    }
}

struct TaskRowView: View {
    @Bindable var task: TaskItem
    @AppStorage("selectedTheme") private var selectedTheme: ZenithTheme = .obsidian
    private var theme: ThemeManager { ThemeManager(theme: selectedTheme) }
    @Environment(\.modelContext) private var modelContext

    @State private var showDatePicker = false
    @State private var pickerDate: Date = Date()
    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 18, weight: .light))
                .foregroundStyle(task.isCompleted ? theme.secondaryForeground : theme.foreground)
                .animation(.easeInOut(duration: 0.25), value: task.isCompleted)

            Image(systemName: "circle.fill")
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(task.priority.color)

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.system(size: 14, weight: .regular, design: .monospaced))
                    .strikethrough(task.isCompleted, color: theme.secondaryForeground)
                    .foregroundStyle(task.isCompleted ? theme.secondaryForeground : theme.foreground)
                    .animation(.easeInOut(duration: 0.25), value: task.isCompleted)
                    .multilineTextAlignment(.leading)

                if let dueDate = task.dueDate {
                    Text(dueDateLabel(dueDate))
                        .font(.system(size: 11, weight: .light, design: .monospaced))
                        .foregroundStyle(theme.secondaryForeground)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                modelContext.delete(task)
                save()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(theme.secondaryForeground)
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)
            .opacity(isHovering ? 1 : 0)
            .animation(.easeInOut(duration: 0.15), value: isHovering)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onHover { isHovering = $0 }
        .onTapGesture {
            task.isCompleted.toggle()
            save()
        }
        .contextMenu {
            Menu("Set Priority") {
                ForEach(TaskPriority.allCases, id: \.self) { p in
                    Button {
                        task.priority = p
                        save()
                    } label: {
                        if task.priority == p {
                            Label(p.label, systemImage: "checkmark")
                        } else {
                            Text(p.label)
                        }
                    }
                }
            }

            Button("Set Due Date") {
                pickerDate = task.dueDate ?? Date()
                showDatePicker = true
            }

            Divider()

            Button(role: .destructive) {
                modelContext.delete(task)
                save()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .popover(isPresented: $showDatePicker) {
            datePicker
        }
    }

    private var datePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            DatePicker("", selection: $pickerDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .onChange(of: pickerDate) {
                    task.dueDate = pickerDate
                    save()
                }

            HStack {
                Button("Clear") {
                    task.dueDate = nil
                    save()
                    showDatePicker = false
                }
                .font(.system(size: 12, design: .monospaced))
                Spacer()
                Button("Done") { showDatePicker = false }
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
            }
        }
        .padding()
        .frame(width: 300)
    }

    private func dueDateLabel(_ date: Date) -> String {
        if !task.isCompleted && date < Calendar.current.startOfDay(for: Date()) {
            return "Overdue"
        }
        return "Due \(dueDateFormatter.string(from: date))"
    }

    private func save() {
        do {
            try modelContext.save()
        } catch {
            logger.error("Failed to save task: \(error.localizedDescription, privacy: .public)")
        }
    }
}

// # MOCK
#Preview {
    let container: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let c = try! ModelContainer(for: TaskItem.self, configurations: config)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let t1 = TaskItem(title: "High priority overdue task", priority: .high, dueDate: yesterday)
        let t2 = TaskItem(title: "Scaffold the project", isCompleted: true)
        c.mainContext.insert(t1)
        c.mainContext.insert(t2)
        return c
    }()
    VStack {
        TaskRowView(task: TaskItem(title: "High priority task",    priority: .high))
        TaskRowView(task: TaskItem(title: "Medium priority task",  priority: .medium))
        TaskRowView(task: TaskItem(title: "Low priority task",     priority: .low))
    }
    .padding()
    .background(Color.black)
    .modelContainer(container)
}
