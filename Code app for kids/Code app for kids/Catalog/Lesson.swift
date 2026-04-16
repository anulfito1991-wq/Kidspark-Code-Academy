import Foundation

struct Lesson: Identifiable, Hashable, Codable, Sendable {
    let id: String
    let languageID: String
    let tier: LessonTier
    let order: Int
    let title: String
    let summary: String
    let xpReward: Int
    let steps: [Step]

    var requiresPro: Bool { tier.requiresPro }
}

struct LessonPack: Codable, Sendable {
    let languageID: String
    let lessons: [Lesson]
}
