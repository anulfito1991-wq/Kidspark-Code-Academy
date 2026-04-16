import SwiftUI

struct Language: Identifiable, Hashable, Codable, Sendable {
    let id: String
    let displayName: String
    let tagline: String
    let iconSystemName: String
    let accentHex: String
    let order: Int

    var accent: Color { Color(hex: accentHex) ?? .accentColor }
}

enum LanguageCatalog {
    static let all: [Language] = [
        Language(
            id: "scratch",
            displayName: "Blocks",
            tagline: "Drag-and-drop coding",
            iconSystemName: "square.stack.3d.up.fill",
            accentHex: "#F59E0B",
            order: 0
        ),
        Language(
            id: "swift",
            displayName: "Swift",
            tagline: "Build apps for Apple devices",
            iconSystemName: "swift",
            accentHex: "#F97316",
            order: 1
        ),
        Language(
            id: "python",
            displayName: "Python",
            tagline: "Great for games and data",
            iconSystemName: "chevron.left.forwardslash.chevron.right",
            accentHex: "#3B82F6",
            order: 2
        ),
        Language(
            id: "javascript",
            displayName: "JavaScript",
            tagline: "The language of the web",
            iconSystemName: "curlybraces",
            accentHex: "#EAB308",
            order: 3
        ),
        Language(
            id: "html",
            displayName: "HTML & CSS",
            tagline: "Build real webpages",
            iconSystemName: "globe",
            accentHex: "#E34C26",
            order: 4
        ),
        Language(
            id: "lua",
            displayName: "Lua",
            tagline: "The language behind Roblox",
            iconSystemName: "gamecontroller.fill",
            accentHex: "#2C2D72",
            order: 5
        ),
        Language(
            id: "java",
            displayName: "Java",
            tagline: "Power apps, games & school CS",
            iconSystemName: "cup.and.saucer.fill",
            accentHex: "#5382A1",
            order: 6
        )
    ]

    static func language(id: String) -> Language? {
        all.first { $0.id == id }
    }
}

extension Color {
    init?(hex: String) {
        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hex.hasPrefix("#") { hex.removeFirst() }
        guard hex.count == 6, let value = UInt32(hex, radix: 16) else { return nil }
        let r = Double((value >> 16) & 0xFF) / 255.0
        let g = Double((value >> 8) & 0xFF) / 255.0
        let b = Double(value & 0xFF) / 255.0
        self = Color(red: r, green: g, blue: b)
    }
}
