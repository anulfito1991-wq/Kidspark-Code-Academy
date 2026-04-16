import Foundation

enum XPService {
    static let xpPerLevel: Int = 100

    static func level(for xp: Int) -> Int {
        max(1, xp / xpPerLevel + 1)
    }

    static func xpIntoLevel(_ xp: Int) -> Int {
        xp % xpPerLevel
    }

    static func xpProgressFraction(_ xp: Int) -> Double {
        Double(xpIntoLevel(xp)) / Double(xpPerLevel)
    }

    static func xpToNextLevel(_ xp: Int) -> Int {
        xpPerLevel - xpIntoLevel(xp)
    }
}
