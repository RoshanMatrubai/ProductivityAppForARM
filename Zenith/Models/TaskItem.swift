import Foundation
import SwiftData

@Model
final class TaskItem {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var createdAt: Date

    init(title: String) {
        self.id = UUID()
        self.title = title
        self.isCompleted = false
        self.createdAt = Date()
    }
}

extension TaskItem {
    // # MOCK
    static var previewItems: [TaskItem] {
        [
            TaskItem(title: "Finish project plan"),
            TaskItem(title: "Review pull requests"),
            TaskItem(title: "Write unit tests"),
        ]
    }
}
