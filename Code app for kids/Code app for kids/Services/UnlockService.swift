import Foundation

enum UnlockService {
    static func status(
        for lesson: Lesson,
        previousLessonInSamePath: Lesson?,
        progressByID: [String: LessonProgress],
        hasPro: Bool
    ) -> NodeStatus {
        if let p = progressByID[lesson.id], p.status == .completed {
            return .completed
        }
        if lesson.requiresPro && !hasPro {
            return .proLocked
        }
        if let prev = previousLessonInSamePath {
            let prevStatus = progressByID[prev.id]?.status
            if prevStatus != .completed {
                return .locked
            }
        }
        if let p = progressByID[lesson.id], p.status == .inProgress {
            return .inProgress
        }
        return .available
    }

    static func firstAvailableLessonID(
        lessons: [Lesson],
        progressByID: [String: LessonProgress],
        hasPro: Bool
    ) -> String? {
        var prev: Lesson?
        for lesson in lessons {
            let s = status(
                for: lesson,
                previousLessonInSamePath: prev,
                progressByID: progressByID,
                hasPro: hasPro
            )
            if s == .available || s == .inProgress { return lesson.id }
            prev = lesson
        }
        return nil
    }

    static func basicsComplete(
        for languageID: String,
        lessons: [Lesson],
        progressByID: [String: LessonProgress]
    ) -> Bool {
        let basics = lessons.filter { $0.tier == .basics }
        guard !basics.isEmpty else { return false }
        return basics.allSatisfy { progressByID[$0.id]?.status == .completed }
    }
}
