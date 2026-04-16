import SwiftUI

enum LessonTier: String, Codable, CaseIterable, Sendable {
    case basics
    case intermediate
    case advanced

    var displayName: String {
        switch self {
        case .basics: return "Basics"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        }
    }

    var requiresPro: Bool {
        self != .basics
    }

    var badgeIcon: String {
        switch self {
        case .basics: return "leaf.fill"
        case .intermediate: return "flame.fill"
        case .advanced: return "bolt.fill"
        }
    }
}

enum NodeStatus: String, Codable, Sendable {
    case locked
    case proLocked
    case available
    case inProgress
    case completed
}
