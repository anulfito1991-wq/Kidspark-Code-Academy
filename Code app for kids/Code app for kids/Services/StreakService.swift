import Foundation

enum StreakService {
    struct Update {
        var newStreak: Int
        var leveledUpStreak: Bool
        var brokeStreak: Bool
    }

    static func touch(
        currentStreak: Int,
        lastActive: Date?,
        freezes: Int,
        now: Date = .now,
        calendar: Calendar = .current
    ) -> Update {
        let today = calendar.startOfDay(for: now)
        guard let last = lastActive else {
            return Update(newStreak: 1, leveledUpStreak: true, brokeStreak: false)
        }
        let lastDay = calendar.startOfDay(for: last)
        let days = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0

        switch days {
        case 0:
            return Update(newStreak: max(currentStreak, 1), leveledUpStreak: false, brokeStreak: false)
        case 1:
            return Update(newStreak: currentStreak + 1, leveledUpStreak: true, brokeStreak: false)
        default:
            if freezes > 0 {
                return Update(newStreak: currentStreak + 1, leveledUpStreak: true, brokeStreak: false)
            }
            return Update(newStreak: 1, leveledUpStreak: true, brokeStreak: true)
        }
    }

    static func shouldConsumeFreeze(
        lastActive: Date?,
        now: Date = .now,
        calendar: Calendar = .current
    ) -> Bool {
        guard let last = lastActive else { return false }
        let today = calendar.startOfDay(for: now)
        let lastDay = calendar.startOfDay(for: last)
        let days = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
        return days > 1
    }
}
