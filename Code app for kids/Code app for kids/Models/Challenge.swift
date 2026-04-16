import Foundation
import SwiftData

@Model
final class Challenge {
    var id: String
    var languageID: String
    var title: String
    var prompt: String
    var options: [String]   // index 0 is always the correct answer
    var xpReward: Int
    var weekID: String      // ISO-8601 week string, e.g. "2026-W16"

    init(
        id: String,
        languageID: String,
        title: String,
        prompt: String,
        options: [String],
        xpReward: Int,
        weekID: String
    ) {
        self.id = id
        self.languageID = languageID
        self.title = title
        self.prompt = prompt
        self.options = options
        self.xpReward = xpReward
        self.weekID = weekID
    }
}

// Lightweight value type used for in-memory catalog (decoded from JSON)
struct ChallengeEntry: Codable, Identifiable {
    let id: String
    let languageID: String
    let title: String
    let prompt: String
    let options: [String]
    let xpReward: Int
    let weekIndex: Int      // 0-based rotation index; mapped to current ISO week mod count
}
