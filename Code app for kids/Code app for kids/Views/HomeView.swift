import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @State private var showChallenge: Bool = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                KidSpark.Colors.pageBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        heroHeader
                        statsPanel
                        if let challenge = appState.activeChallenge {
                            ChallengeCard(
                                entry: challenge,
                                isCompleted: appState.isChallengeCompleted()
                            ) {
                                showChallenge = true
                            }
                            .padding(.horizontal, KidSpark.Layout.pagePadding)
                            .offset(y: -14)
                        }
                        languagesSection
                        Spacer(minLength: 24)
                    }
                }
            }
            .sheet(isPresented: $showChallenge) {
                if let challenge = appState.activeChallenge {
                    ChallengeView(entry: challenge)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    KidSpark.WordMark()
                }
            }
            .navigationDestination(for: Language.self) { lang in
                LanguagePathView(language: lang)
            }
        }
    }

    // MARK: Hero header

    private var heroHeader: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 0)
                .fill(KidSpark.Colors.heroGradient)
                .frame(height: 170)
                .ignoresSafeArea(edges: .top)

            // Decorative circles
            Circle()
                .fill(.white.opacity(0.06))
                .frame(width: 140, height: 140)
                .offset(x: 280, y: -10)
            Circle()
                .fill(.white.opacity(0.06))
                .frame(width: 80, height: 80)
                .offset(x: 240, y: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text("Hi, \(appState.learner.displayName)! 👋")
                    .font(KidSpark.Fonts.title2)
                    .foregroundStyle(.white)
                Text(motivationalGreeting)
                    .font(KidSpark.Fonts.callout)
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding(.horizontal, KidSpark.Layout.pagePadding)
            .padding(.bottom, 22)
        }
    }

    private var motivationalGreeting: String {
        let xp = appState.learner.xp
        let streak = appState.learner.streakDays
        if streak >= 7 { return "7-day streak — you're a coding hero! 🦸" }
        if streak >= 3 { return "On a roll! Keep that streak alive 🔥" }
        if xp >= 200 { return "You're unstoppable — pick a language! 🚀" }
        if xp >= 50 { return "You're sparking! Keep the momentum going ⚡" }
        return "Pick a language and start your spark! ⚡"
    }

    // MARK: Stats panel

    private var statsPanel: some View {
        VStack(spacing: 14) {
            XPBar(xp: appState.learner.xp)
            Divider()
            HStack {
                StreakPill(days: appState.learner.streakDays)
                Spacer()
                if appState.hasPro {
                    ProChip()
                } else {
                    Text("\(appState.progressByID.values.filter { $0.status == .completed }.count) lessons done")
                        .font(KidSpark.Fonts.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .kidSparkCard()
        .padding(.horizontal, KidSpark.Layout.pagePadding)
        .offset(y: -24)
    }

    // MARK: Language grid

    private var languagesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Choose your language")
                .font(KidSpark.Fonts.headline)
                .padding(.horizontal, KidSpark.Layout.pagePadding)
                .offset(y: -16)

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)],
                spacing: 14
            ) {
                ForEach(appState.catalog.languages) { lang in
                    NavigationLink(value: lang) {
                        LanguageTile(language: lang, progress: progressFraction(for: lang.id))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, KidSpark.Layout.pagePadding)
            .offset(y: -16)
        }
    }

    private func progressFraction(for languageID: String) -> Double {
        let lessons = appState.catalog.lessons(for: languageID).filter { $0.tier == .basics }
        guard !lessons.isEmpty else { return 0 }
        let done = lessons.filter { appState.progress(for: $0.id)?.status == .completed }.count
        return Double(done) / Double(lessons.count)
    }
}

// MARK: - Language tile

private struct LanguageTile: View {
    let language: Language
    let progress: Double

    @State private var pressed: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top color band
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(colors: [language.accent, language.accent.opacity(0.7)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(height: 90)

                // Decorative circle
                Circle()
                    .fill(.white.opacity(0.12))
                    .frame(width: 60, height: 60)
                    .offset(x: 100, y: 10)

                HStack(alignment: .bottom) {
                    Image(systemName: language.iconSystemName)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(12)
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(KidSpark.Fonts.caption)
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(10)
                }
            }

            // Bottom info
            VStack(alignment: .leading, spacing: 6) {
                Text(language.displayName)
                    .font(KidSpark.Fonts.headline)
                Text(language.tagline)
                    .font(KidSpark.Fonts.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                ProgressView(value: progress)
                    .tint(language.accent)
                    .scaleEffect(x: 1, y: 1.4, anchor: .center)
            }
            .padding(14)
        }
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous))
        .shadow(color: language.accent.opacity(0.2), radius: 10, y: 4)
        .scaleEffect(pressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: pressed)
        .onLongPressGesture(minimumDuration: 0, pressing: { p in pressed = p }, perform: {})
    }
}
