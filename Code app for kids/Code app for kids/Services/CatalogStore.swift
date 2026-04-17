import Foundation
import Observation

@Observable
@MainActor
final class CatalogStore {
    private(set) var languages: [Language] = LanguageCatalog.all
    private(set) var lessonsByLanguage: [String: [Lesson]] = [:]
    private(set) var lessonsByID: [String: Lesson] = [:]
    private(set) var loadError: String?
    private(set) var isReady: Bool = false

    /// Async-loads the bundled lesson JSON off the main thread.
    /// Returns immediately if already loaded.
    func loadIfNeeded() async {
        guard !isReady else { return }
        let languageIDs = languages.map(\.id)

        // Decode on a background task. Bundle URL lookups and file reads are
        // safe off-main; we only hop back to @MainActor to publish results.
        let result = await Task.detached(priority: .userInitiated) { () -> LoadResult in
            var byLang: [String: [Lesson]] = [:]
            var byID: [String: Lesson] = [:]
            var firstError: String?
            let decoder = JSONDecoder()

            for langID in languageIDs {
                guard let url = Self.bundleURL(for: langID) else {
                    firstError = firstError ?? "Missing lesson file for \(langID)"
                    continue
                }
                do {
                    let data = try Data(contentsOf: url)
                    let pack = try decoder.decode(LessonPack.self, from: data)
                    let ordered = pack.lessons.sorted { $0.order < $1.order }
                    byLang[langID] = ordered
                    for l in ordered { byID[l.id] = l }
                } catch {
                    firstError = firstError ?? "Failed to load \(langID): \(error.localizedDescription)"
                }
            }
            return LoadResult(byLang: byLang, byID: byID, error: firstError)
        }.value

        self.lessonsByLanguage = result.byLang
        self.lessonsByID = result.byID
        self.loadError = result.error
        self.isReady = true
    }

    private struct LoadResult: Sendable {
        let byLang: [String: [Lesson]]
        let byID: [String: Lesson]
        let error: String?
    }

    nonisolated private static func bundleURL(for languageID: String) -> URL? {
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
