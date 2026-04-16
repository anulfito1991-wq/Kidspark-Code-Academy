import SwiftUI

struct Badge: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let description: String
    let emoji: String
    let iconSystemName: String
    let accentHex: String
    let rule: BadgeRule

    var accent: Color { Color(hex: accentHex) ?? KidSpark.Colors.spark }
}

enum BadgeRule: Hashable, Sendable {
    case firstLesson
    case streak(days: Int)
    case completeTier(languageID: String, tier: LessonTier)
    case earnXP(amount: Int)
}

enum BadgeCatalog {
    static let all: [Badge] = [
        Badge(
            id: "first_step",
            title: "First Spark! ⚡",
            description: "You finished your very first lesson. The journey of a thousand apps starts with a single line!",
            emoji: "⚡",
            iconSystemName: "bolt.circle.fill",
            accentHex: "#7C3AED",
            rule: .firstLesson
        ),
        Badge(
            id: "streak_3",
            title: "3-Day Rocket 🚀",
            description: "Three days in a row! You're building the habit that separates dreamers from makers.",
            emoji: "🚀",
            iconSystemName: "flame.fill",
            accentHex: "#F97316",
            rule: .streak(days: 3)
        ),
        Badge(
            id: "streak_7",
            title: "Weekly Hero 🦸",
            description: "A full week of coding! Most people stop way before this — not you.",
            emoji: "🦸",
            iconSystemName: "calendar.badge.checkmark",
            accentHex: "#F43F5E",
            rule: .streak(days: 7)
        ),
        Badge(
            id: "xp_100",
            title: "Level 2 Legend 🌟",
            description: "100 XP earned! Your brain is growing stronger every lesson — that's real science.",
            emoji: "🌟",
            iconSystemName: "star.circle.fill",
            accentHex: "#F59E0B",
            rule: .earnXP(amount: 100)
        ),
        Badge(
            id: "xp_500",
            title: "Spark Champion ✨",
            description: "500 XP! You are officially a KidSpark coder. Not everyone makes it this far — you did.",
            emoji: "✨",
            iconSystemName: "sparkles",
            accentHex: "#7C3AED",
            rule: .earnXP(amount: 500)
        ),
        Badge(
            id: "swift_basics",
            title: "Swift Sprout 🌱",
            description: "All Swift Basics done! You just learned what powers millions of apps on your phone.",
            emoji: "🌱",
            iconSystemName: "swift",
            accentHex: "#F97316",
            rule: .completeTier(languageID: "swift", tier: .basics)
        ),
        Badge(
            id: "python_basics",
            title: "Python Pilot 🐍",
            description: "All Python Basics complete! One of the most popular coding languages in the world — and you know it.",
            emoji: "🐍",
            iconSystemName: "chevron.left.forwardslash.chevron.right",
            accentHex: "#3B82F6",
            rule: .completeTier(languageID: "python", tier: .basics)
        ),
        Badge(
            id: "javascript_basics",
            title: "Web Wizard 🧙",
            description: "All JavaScript Basics conquered! Every website you visit uses this language.",
            emoji: "🧙",
            iconSystemName: "curlybraces",
            accentHex: "#EAB308",
            rule: .completeTier(languageID: "javascript", tier: .basics)
        ),
        Badge(
            id: "scratch_basics",
            title: "Block Builder 🧱",
            description: "All Block Basics finished! You learned to think like a programmer, no typing needed.",
            emoji: "🧱",
            iconSystemName: "square.stack.3d.up.fill",
            accentHex: "#10B981",
            rule: .completeTier(languageID: "scratch", tier: .basics)
        ),
        Badge(
            id: "html_basics",
            title: "Web Architect 🌐",
            description: "All HTML & CSS Basics done! You can now build real webpages that anyone in the world can see.",
            emoji: "🌐",
            iconSystemName: "globe",
            accentHex: "#E34C26",
            rule: .completeTier(languageID: "html", tier: .basics)
        ),
        Badge(
            id: "lua_basics",
            title: "Roblox Ready 🎮",
            description: "All Lua Basics complete! The same language that powers Roblox games is now in your toolkit.",
            emoji: "🎮",
            iconSystemName: "gamecontroller.fill",
            accentHex: "#2C2D72",
            rule: .completeTier(languageID: "lua", tier: .basics)
        ),
        Badge(
            id: "java_basics",
            title: "Java Hero ☕",
            description: "All Java Basics conquered! You know the language taught in schools worldwide — and used to build Minecraft.",
            emoji: "☕",
            iconSystemName: "cup.and.saucer.fill",
            accentHex: "#5382A1",
            rule: .completeTier(languageID: "java", tier: .basics)
        )
    ]

    static func badge(id: String) -> Badge? {
        all.first { $0.id == id }
    }
}
