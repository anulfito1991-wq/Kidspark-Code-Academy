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
    var ageGateCompleted: Bool
    var isUnder13: Bool
    var parentConsentDate: Date?

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
        createdAt: Date = .now,
        ageGateCompleted: Bool = false,
        isUnder13: Bool = false,
        parentConsentDate: Date? = nil
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
        self.ageGateCompleted = ageGateCompleted
        self.isUnder13 = isUnder13
        self.parentConsentDate = parentConsentDate
    }
}
