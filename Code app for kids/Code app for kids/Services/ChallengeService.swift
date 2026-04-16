import Foundation

enum ChallengeService {
    // Returns the ISO 8601 year-week string for `date`, e.g. "2026-W16"
    static func weekID(for date: Date = .now) -> String {
        let cal = Calendar(identifier: .iso8601)
        let week = cal.component(.weekOfYear, from: date)
        let year = cal.component(.yearForWeekOfYear, from: date)
        return String(format: "%04d-W%02d", year, week)
    }

    // Picks the entry whose weekIndex matches currentWeek mod total count.
    static func activeEntry(from entries: [ChallengeEntry], date: Date = .now) -> ChallengeEntry? {
        guard !entries.isEmpty else { return nil }
        let cal = Calendar(identifier: .iso8601)
        let week = cal.component(.weekOfYear, from: date)
        let idx = (week - 1) % entries.count
        return entries.first { $0.weekIndex == idx } ?? entries[idx % entries.count]
    }

    static func hasCompleted(weekID: String, completedIDs: [String]) -> Bool {
        completedIDs.contains("challenge_\(weekID)")
    }

    static func storageKey(for weekID: String) -> String {
        "challenge_\(weekID)"
    }

    // Seconds until next Monday 00:00 local time
    static func secondsUntilNextWeek(from date: Date = .now) -> TimeInterval {
        var cal = Calendar(identifier: .iso8601)
        cal.locale = Locale.current
        var comps = DateComponents()
        comps.weekday = 2   // Monday in ISO: 2
        comps.hour = 0
        comps.minute = 0
        comps.second = 0
        guard let next = cal.nextDate(after: date, matching: comps, matchingPolicy: .nextTime) else {
            return 7 * 24 * 3600
        }
        return next.timeIntervalSince(date)
    }

    static func loadEntries() -> [ChallengeEntry] {
        guard let url = Bundle.main.url(forResource: "challenges", withExtension: "json",
                                        subdirectory: "Lessons")
                ?? Bundle.main.url(forResource: "challenges", withExtension: "json") else {
            return []
        }
        let data = (try? Data(contentsOf: url)) ?? Data()
        return (try? JSONDecoder().decode([ChallengeEntry].self, from: data)) ?? []
    }
}
