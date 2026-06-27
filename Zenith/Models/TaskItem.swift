import Foundation
import SwiftData

enum TaskPriority: Int16, Codable, CaseIterable {
    case low    = 0
    case medium = 1
    case high   = 2

    var label: String {
        switch self {
        case .low:    "Low"
        case .medium: "Medium"
        case .high:   "High"
        }
    }

    var dotOpacity: Double {
        switch self {
        case .low:    0.3
        case .medium: 0.6
        case .high:   1.0
        }
    }
}

@Model
final class TaskItem {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var createdAt: Date
    var priorityRaw: Int16 = 1  // TaskPriority.medium — SwiftData uses this for existing rows on migration
    var dueDate: Date?

    var priority: TaskPriority {
        get { TaskPriority(rawValue: priorityRaw) ?? .medium }
        set { priorityRaw = newValue.rawValue }
    }

    init(title: String, isCompleted: Bool = false, priority: TaskPriority = .medium, dueDate: Date? = nil) {
        self.id = UUID()
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = Date()
        self.priorityRaw = priority.rawValue
        self.dueDate = dueDate
    }
}

extension TaskItem {
    // # MOCK
    static var previewItems: [TaskItem] {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let tomorrow  = Calendar.current.date(byAdding: .day, value: +1, to: Date())!
        return [
            TaskItem(title: "Finish project plan",  priority: .high,   dueDate: yesterday),
            TaskItem(title: "Review pull requests", priority: .medium, dueDate: tomorrow),
            TaskItem(title: "Write unit tests",     priority: .low),
        ]
    }
}
