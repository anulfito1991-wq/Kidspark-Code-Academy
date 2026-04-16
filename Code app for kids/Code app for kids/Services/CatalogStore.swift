import Foundation
import Observation

@Observable
@MainActor
final class CatalogStore {
    private(set) var languages: [Language] = LanguageCatalog.all
    private(set) var lessonsByLanguage: [String: [Lesson]] = [:]
    private(set) var lessonsByID: [String: Lesson] = [:]
    private(set) var loadError: String?

    func loadIfNeeded() {
        guard lessonsByLanguage.isEmpty else { return }
        load()
    }

    private func load() {
        var byLang: [String: [Lesson]] = [:]
        var byID: [String: Lesson] = [:]
        let decoder = JSONDecoder()

        for lang in languages {
            guard let url = Self.bundleURL(for: lang.id) else {
                loadError = "Missing lesson file for \(lang.id)"
                continue
            }
            do {
                let data = try Data(contentsOf: url)
                let pack = try decoder.decode(LessonPack.self, from: data)
                let ordered = pack.lessons.sorted { $0.order < $1.order }
                byLang[lang.id] = ordered
                for l in ordered { byID[l.id] = l }
            } catch {
                loadError = "Failed to load \(lang.id): \(error.localizedDescription)"
            }
        }

        self.lessonsByLanguage = byLang
        self.lessonsByID = byID
    }

    private static func bundleURL(for languageID: String) -> URL? {
        if let url = Bundle.main.url(forResource: languageID, withExtension: "json", subdirectory: "Lessons") {
            return url
        }
        return Bundle.main.url(forResource: languageID, withExtension: "json")
    }

    func lessons(for languageID: String) -> [Lesson] {
        lessonsByLanguage[languageID] ?? []
    }

    func lesson(id: String) -> Lesson? {
        lessonsByID[id]
    }

    func basicsCount(for languageID: String) -> Int {
        lessons(for: languageID).filter { $0.tier == .basics }.count
    }
}
