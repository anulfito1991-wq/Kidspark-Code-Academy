import Foundation

enum UnlockService {
    /// Per-lesson status. The optional `freeIntermediateLessonID` argument
    /// implements the freemium "taste" — exactly one intermediate lesson per
    /// language opens after Basics complete even when the user doesn't own
    /// Pro. Pass `nil` for strict Pro gating.
    static func status(
        for lesson: Lesson,
        previousLessonInSamePath: Lesson?,
        progressByID: [String: LessonProgress],
        hasPro: Bool,
        freeIntermediateLessonID: String? = nil
    ) -> NodeStatus {
        if let p = progressByID[lesson.id], p.status == .completed {
            return .completed
        }
        if lesson.requiresPro && !hasPro {
            // Freemium exception: the one "taste" lesson is playable, but only
            // once basics are done (otherwise prerequisite check below catches it).
            if lesson.id != freeIntermediateLessonID {
                return .proLocked
            }
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
        let freeID = freeIntermediateLessonID(in: lessons, hasPro: hasPro)
        var prev: Lesson?
        for lesson in lessons {
            let s = status(
                for: lesson,
                previousLessonInSamePath: prev,
                progressByID: progressByID,
                hasPro: hasPro,
                freeIntermediateLessonID: freeID
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

    /// Returns the lesson that should unlock as the free "taste" intermediate
    /// for non-Pro users. Picks the first lesson that `requiresPro` in order.
    /// Returns `nil` when the user already owns Pro, or when the path has no
    /// pro-gated lesson at all.
    static func freeIntermediateLessonID(in lessons: [Lesson], hasPro: Bool) -> String? {
        guard !hasPro else { return nil }
        return lessons.first(where: { $0.requiresPro })?.id
    }
}
