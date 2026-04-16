import Foundation
import SwiftData

@Model
final class Learner {
    var displayName: String
    var xp: Int
    var streakDays: Int
    var streakFreezes: Int
    var lastActiveDate: Date?
    var hasProCached: Bool
    var earnedBadgeIDs: [String]
    var completedChallengeIDs: [String]   // stores "challenge_<weekID>"
    var dailyGoal: Int
    var createdAt: Date

    init(
        displayName: String = "Coder",
        xp: Int = 0,
        streakDays: Int = 0,
        streakFreezes: Int = 0,
        lastActiveDate: Date? = nil,
        hasProCached: Bool = false,
        earnedBadgeIDs: [String] = [],
        completedChallengeIDs: [String] = [],
        dailyGoal: Int = 1,
        createdAt: Date = .now
    ) {
        self.displayName = displayName
        self.xp = xp
        self.streakDays = streakDays
        self.streakFreezes = streakFreezes
        self.lastActiveDate = lastActiveDate
        self.hasProCached = hasProCached
        self.earnedBadgeIDs = earnedBadgeIDs
        self.completedChallengeIDs = completedChallengeIDs
        self.dailyGoal = dailyGoal
        self.createdAt = createdAt
    }
}
