import SwiftUI

struct LanguagePathView: View {
    let language: Language

    @Environment(AppState.self) private var appState
    @State private var selectedLesson: Lesson?
    @State private var showPaywall: Bool = false

    // Cached derived state. Recomputed on appear and when progress / Pro flips.
    @State private var statusCache: [String: NodeStatus] = [:]
    @State private var highlightedLessonID: String?

    private var lessons: [Lesson] {
        appState.catalog.lessons(for: language.id)
    }

    private var completed: Int {
        lessons.filter { statusCache[$0.id] == .completed }.count
    }

    private func recomputeStatuses() {
        let freeID = UnlockService.freeIntermediateLessonID(
            in: lessons,
            hasPro: appState.hasPro
        )
        var statuses: [String: NodeStatus] = [:]
        var previousLesson: Lesson?
        for lesson in lessons {
            let status = UnlockService.status(
                for: lesson,
                previousLessonInSamePath: previousLesson,
                progressByID: appState.progressByID,
                hasPro: appState.hasPro,
                freeIntermediateLessonID: freeID
            )
            statuses[lesson.id] = status
            previousLesson = lesson
        }
        statusCache = statuses
        highlightedLessonID = UnlockService.firstAvailableLessonID(
            lessons: lessons,
            progressByID: appState.progressByID,
            hasPro: appState.hasPro
        )
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Colour band header
                ZStack(alignment: .bottomLeading) {
                    LinearGradient(
                        colors: [language.accent, language.accent.opacity(0.6)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                    .frame(height: 120)

                    // Decorative circle
                    Circle()
                        .fill(.white.opacity(0.08))
                        .frame(width: 100)
                        .offset(x: 280, y: 20)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(language.tagline)
                            .font(KidSpark.Fonts.callout)
                            .foregroundStyle(.white.opacity(0.85))
                        Text("\(completed) of \(lessons.count) lessons done")
                            .font(KidSpark.Fonts.headline)
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 18)
                }

                // Tree
                TreeBranchLayout(
                    lessons: lessons,
                    statuses: statusCache,
                    highlightedLessonID: highlightedLessonID,
                    accent: language.accent,
                    onTap: handleTap
                )
                .padding(.top, 16)
                .padding(.horizontal, 8)
            }
        }
        .background(KidSpark.Colors.pageBackground.ignoresSafeArea())
        .navigationTitle(language.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { recomputeStatuses() }
        .onChange(of: appState.progressByID.count) { _, _ in recomputeStatuses() }
        .onChange(of: appState.hasPro) { _, _ in recomputeStatuses() }
        .onChange(of: lessons.count) { _, _ in recomputeStatuses() }
        .sheet(item: $selectedLesson) { lesson in
            NavigationStack {
                LessonView(lesson: lesson, language: language)
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    private func handleTap(_ lesson: Lesson) {
        let status = statusCache[lesson.id] ?? .locked
        switch status {
        case .locked: break
        case .proLocked: showPaywall = true
        case .available, .inProgress, .completed: selectedLesson = lesson
        }
    }
}
