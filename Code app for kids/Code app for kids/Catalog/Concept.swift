import Foundation

/// High-level CS concept tags surfaced to parents on the dashboard.
/// Derived from lesson titles rather than stored per-lesson — keeps the JSON
/// catalog untouched and lets new lessons auto-tag via keyword match.
enum Concept: String, CaseIterable, Identifiable {
    case hello            // intro / "Hello, X"
    case variables
    case numbers          // math, arithmetic
    case strings
    case conditionals     // if/else
    case loops            // for / forever / repeat
    case functions        // def / methods / custom blocks
    case lists            // arrays / lists
    case events           // "when flag clicked", etc.
    case structure        // HTML structure, elements
    case styling          // CSS / visuals
    case motion           // "move the cat" / sprites

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .hello:        return "Getting Started"
        case .variables:    return "Variables"
        case .numbers:      return "Numbers & Math"
        case .strings:      return "Strings"
        case .conditionals: return "If / Else"
        case .loops:        return "Loops"
        case .functions:    return "Functions"
        case .lists:        return "Lists"
        case .events:       return "Events"
        case .structure:    return "Page Structure"
        case .styling:      return "Styling"
        case .motion:       return "Motion"
        }
    }

    var emoji: String {
        switch self {
        case .hello:        return "👋"
        case .variables:    return "📦"
        case .numbers:      return "➕"
        case .strings:      return "🔤"
        case .conditionals: return "🔀"
        case .loops:        return "🔁"
        case .functions:    return "🧩"
        case .lists:        return "📋"
        case .events:       return "⚡"
        case .structure:    return "🏗️"
        case .styling:      return "🎨"
        case .motion:       return "🏃"
        }
    }
}

enum ConceptTagger {
    /// Returns the concepts this lesson teaches. Title-keyword based so it
    /// works even when JSON doesn't carry explicit tags.
    static func concepts(for lesson: Lesson) -> [Concept] {
        let t = lesson.title.lowercased()
        var out: [Concept] = []

        if t.hasPrefix("hello") || t.contains("what is") || t.contains("first webpage") {
            out.append(.hello)
        }
        if t.contains("variable") || t.contains("let and const") || t.contains("boxes called") {
            out.append(.variables)
        }
        if t.contains("math") || t.contains("number") {
            out.append(.numbers)
        }
        if t.contains("string") || t.contains("f-string") || t.contains("template string")
            || t.contains("working with words") || t.contains("say and think") {
            out.append(.strings)
        }
        if t.contains("if") || t.contains("else") || t.contains("making choices") {
            out.append(.conditionals)
        }
        if t.contains("loop") || t.contains("forever") || t.contains("doing it again") || t.contains("repeat") {
            out.append(.loops)
        }
        if t.contains("function") || t.contains("method") || t.contains("def")
            || t.contains("make your own block") {
            out.append(.functions)
        }
        if t.contains("array") || t.contains("list") {
            out.append(.lists)
        }
        if t.contains("when flag") || t.contains("event") {
            out.append(.events)
        }
        if t.contains("paragraph") || t.contains("link") || t.contains("image")
            || t.contains("webpage") || t.contains("block?") {
            out.append(.structure)
        }
        if t.contains("css") || t.contains("style") {
            out.append(.styling)
        }
        if t.contains("move") || t.contains("motion") {
            out.append(.motion)
        }

        return out.isEmpty ? [.hello] : out
    }

    /// Concepts derived from the learner's completed lessons, with counts.
    /// Sorted by count desc, then by concept order. Pass already-completed
    /// `Lesson` objects.
    static func summary(forCompletedLessons completed: [Lesson]) -> [(Concept, Int)] {
        var counts: [Concept: Int] = [:]
        for lesson in completed {
            for c in Set(concepts(for: lesson)) {
                counts[c, default: 0] += 1
            }
        }
        return counts.sorted { lhs, rhs in
            if lhs.value != rhs.value { return lhs.value > rhs.value }
            return lhs.key.rawValue < rhs.key.rawValue
        }
    }
}
