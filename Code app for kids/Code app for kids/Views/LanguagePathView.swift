import SwiftUI

struct LanguagePathView: View {
    let language: Language

    @Environment(AppState.self) private var appState
    @State private var selectedLesson: Lesson?
    @State private var showPaywall: Bool = false

    private var lessons: [Lesson] {
        appState.catalog.lessons(for: language.id)
    }

    private var completed: Int {
        lessons.filter { appState.progress(for: $0.id)?.status == .completed }.count
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
                    statusProvider: { appState.status(for: $0, in: lessons) },
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
        let status = appState.status(for: lesson, in: lessons)
        switch status {
        case .locked: break
        case .proLocked: showPaywall = true
        case .available, .inProgress, .completed: selectedLesson = lesson
        }
    }
}
