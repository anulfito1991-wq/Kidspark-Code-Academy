import Foundation

enum BadgeService {
    struct EvaluationContext {
        let xp: Int
        let streakDays: Int
        let completedLessonCount: Int
        let lessonsByLanguage: [String: [Lesson]]
        let progressByID: [String: LessonProgress]
    }

    static func newlyEarned(
        alreadyEarned: Set<String>,
        context: EvaluationContext
    ) -> [Badge] {
        BadgeCatalog.all.compactMap { badge in
            guard !alreadyEarned.contains(badge.id) else { return nil }
            return qualifies(for: badge, context: context) ? badge : nil
        }
    }

    private static func qualifies(for badge: Badge, context: EvaluationContext) -> Bool {
        switch badge.rule {
        case .firstLesson:
            return context.completedLessonCount >= 1
        case .streak(let days):
            return context.streakDays >= days
        case .earnXP(let amount):
            return context.xp >= amount
        case .completeTier(let languageID, let tier):
            let lessons = (context.lessonsByLanguage[languageID] ?? []).filter { $0.tier == tier }
            guard !lessons.isEmpty else { return false }
            return lessons.allSatisfy { context.progressByID[$0.id]?.status == .completed }
        }
    }
}
