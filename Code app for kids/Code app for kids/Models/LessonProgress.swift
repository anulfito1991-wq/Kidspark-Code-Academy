import Foundation
import SwiftData

@Model
final class LessonProgress {
    @Attribute(.unique) var lessonID: String
    var languageID: String
    var statusRaw: String
    var bestScore: Int
    var attempts: Int
    var completedAt: Date?
    var lastOpenedAt: Date?

    var status: NodeStatus {
        get { NodeStatus(rawValue: statusRaw) ?? .available }
        set { statusRaw = newValue.rawValue }
    }

    init(
        lessonID: String,
        languageID: String,
        status: NodeStatus = .available,
        bestScore: Int = 0,
        attempts: Int = 0,
        completedAt: Date? = nil,
        lastOpenedAt: Date? = nil
    ) {
        self.lessonID = lessonID
        self.languageID = languageID
        self.statusRaw = status.rawValue
        self.bestScore = bestScore
        self.attempts = attempts
        self.completedAt = completedAt
        self.lastOpenedAt = lastOpenedAt
    }
}
