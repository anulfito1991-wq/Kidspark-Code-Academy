import SwiftUI
import UserNotifications

struct ParentDashboardView: View {
    var body: some View {
        ParentPINGate {
            ParentDashboardContent()
        }
    }
}

private struct ParentDashboardContent: View {
    @Environment(AppState.self) private var appState
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    private var notificationsAuthorized: Bool { notificationStatus == .authorized }

    private var learner: Learner { appState.learner }
    private var progressByID: [String: LessonProgress] { appState.progressByID }

    // Last 7 days activity: (dayLabel, completionCount)
    private var weeklyActivity: [(String, Int)] {
        let cal = Calendar.current
        let fmt = DateFormatter()
        fmt.dateFormat = "E"   // Mon, Tue…
        return (0..<7).reversed().map { offset -> (String, Int) in
            let day = cal.date(byAdding: .day, value: -offset, to: .now)!
            let count = progressByID.values.filter {
                guard let d = $0.completedAt else { return false }
                return cal.isDate(d, inSameDayAs: day)
            }.count
            return (fmt.string(from: day), count)
        }
    }

    private var totalLessons: Int { progressByID.count }
    private var completedLessons: Int { progressByID.values.filter { $0.status == .completed }.count }
    private var estimatedMinutes: Int { progressByID.values.reduce(0) { $0 + $1.attempts } * 2 }

    private var languageProgress: [(Language, Int, Int)] {
        appState.catalog.languages.map { lang in
            let all = appState.catalog.lessons(for: lang.id)
            let basics = all.filter { $0.tier == .basics }
            let done = basics.filter { progressByID[$0.id]?.status == .completed }.count
            return (lang, done, basics.count)
        }
    }

    // MARK: Notifications row state

    private var notificationSubtitle: String {
        switch notificationStatus {
        case .authorized, .provisional, .ephemeral:
            return "On — streak & challenge reminders"
        case .denied:
            return "Off — enable in iOS Settings"
        case .notDetermined:
            return "Off — tap Enable to turn on reminders"
        @unknown default:
            return "Off"
        }
    }

    @ViewBuilder
    private var notificationActionButton: some View {
        switch notificationStatus {
        case .notDetermined:
            // Parent-initiated prompt — required for Kids Category compliance.
            Button("Enable") {
                Task {
                    _ = await NotificationService.requestPermission()
                    notificationStatus = await NotificationService.authorizationStatus()
                }
            }
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(KidSpark.Colors.spark, in: Capsule())
        case .denied, .authorized, .provisional, .ephemeral:
            Button("Manage") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(KidSpark.Colors.spark)
        @unknown default:
            EmptyView()
        }
    }

    // Concepts the learner has been exposed to, ranked by frequency.
    // Derived each render from completed progress + catalog — no new storage.
    private var conceptSummary: [(Concept, Int)] {
        let completedLessons: [Lesson] = progressByID.values
            .filter { $0.status == .completed }
            .compactMap { appState.catalog.lesson(id: $0.lessonID) }
        return Array(ConceptTagger.summary(forCompletedLessons: completedLessons).prefix(6))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Summary strip
                    HStack(spacing: 0) {
                        StatCell(value: "\(XPService.level(for: learner.xp))", label: "Level")
                        Divider().frame(height: 40)
                        StatCell(value: "\(learner.xp)", label: "Total XP")
                        Divider().frame(height: 40)
                        StatCell(value: "\(learner.streakDays)", label: "Day streak")
                        Divider().frame(height: 40)
                        StatCell(value: "\(estimatedMinutes)m", label: "Est. time")
                    }
                    .padding(.vertical, 14)
                    .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 4)

                    // Last active
                    if let last = learner.lastActiveDate {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundStyle(KidSpark.Colors.sky)
                            Text("Last active: \(last, style: .relative)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal, 4)
                    }

                    // Weekly bar chart
                    DashboardCard(title: "This Week", icon: "chart.bar.fill", accent: KidSpark.Colors.spark) {
                        WeeklyBarChart(data: weeklyActivity)
                            .frame(height: 80)
                    }

                    // Concepts learned
                    if !conceptSummary.isEmpty {
                        DashboardCard(title: "Concepts Learned", icon: "brain.head.profile", accent: KidSpark.Colors.coral) {
                            // Flexible wrap of concept chips.
                            FlexibleChipGrid(items: conceptSummary, spacing: 8) { concept, count in
                                ConceptChip(concept: concept, count: count)
                            }
                        }
                    }

                    // Language progress — each row drills into the lesson list.
                    DashboardCard(title: "Languages", icon: "list.bullet", accent: KidSpark.Colors.sky) {
                        VStack(spacing: 10) {
                            ForEach(languageProgress, id: \.0.id) { lang, done, total in
                                NavigationLink {
                                    LanguageLessonDrillDown(language: lang)
                                        .environment(appState)
                                } label: {
                                    HStack(spacing: 10) {
                                        LanguageProgressRow(language: lang, done: done, total: total)
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundStyle(.tertiary)
                                    }
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // Daily goal stepper (mirrors the one in Profile so parents
                    // can set a target without swiping through tabs).
                    DashboardCard(title: "Daily Goal", icon: "target", accent: KidSpark.Colors.leaf) {
                        DailyGoalStepper()
                    }

                    // Lessons summary
                    DashboardCard(title: "Lessons", icon: "checkmark.seal.fill", accent: KidSpark.Colors.leaf) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(completedLessons) completed")
                                    .font(.system(size: 16, weight: .bold))
                                Text("out of \(appState.catalog.languages.reduce(0) { $0 + appState.catalog.lessons(for: $1.id).filter { $0.tier == .basics }.count }) basics lessons")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            CircleProgress(fraction: totalLessons > 0
                                           ? Double(completedLessons) / Double(max(1, appState.catalog.languages.reduce(0) { $0 + appState.catalog.lessons(for: $1.id).filter { $0.tier == .basics }.count }))
                                           : 0,
                                           color: KidSpark.Colors.leaf)
                                .frame(width: 52, height: 52)
                        }
                    }

                    // Badges
                    let earnedBadges = BadgeCatalog.all.filter { appState.learner.earnedBadgeIDs.contains($0.id) }
                    if !earnedBadges.isEmpty {
                        DashboardCard(title: "Badges Earned", icon: "rosette", accent: KidSpark.Colors.glow) {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                                ForEach(earnedBadges) { badge in
                                    VStack(spacing: 4) {
                                        Text(badge.emoji)
                                            .font(.system(size: 28))
                                        Text(badge.title)
                                            .font(.system(size: 9, weight: .semibold))
                                            .multilineTextAlignment(.center)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }

                    // Settings card — age declaration + notifications
                    DashboardCard(title: "Settings", icon: "gearshape.fill", accent: KidSpark.Colors.sky) {
                        VStack(spacing: 14) {
                            HStack {
                                Image(systemName: "person.crop.circle")
                                    .foregroundStyle(.secondary)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Age declared")
                                        .font(.system(size: 13, weight: .semibold))
                                    Text(learner.isUnder13 ? "Under 13" : "13 or older")
                                        .font(.system(size: 12))
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                            Divider()
                            HStack {
                                Image(systemName: notificationsAuthorized ? "bell.fill" : "bell.slash.fill")
                                    .foregroundStyle(notificationsAuthorized ? KidSpark.Colors.spark : .secondary)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Notifications")
                                        .font(.system(size: 13, weight: .semibold))
                                    Text(notificationSubtitle)
                                        .font(.system(size: 12))
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                notificationActionButton
                            }
                        }
                    }

                    // Challenges
                    let challengesWon = learner.completedChallengeIDs.count
                    if challengesWon > 0 {
                        DashboardCard(title: "Weekly Challenges", icon: "bolt.fill", accent: KidSpark.Colors.spark) {
                            HStack {
                                Text("⚡ \(challengesWon) challenge\(challengesWon == 1 ? "" : "s") completed")
                                    .font(.system(size: 15, weight: .semibold))
                                Spacer()
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .background(KidSpark.Colors.pageBackground.ignoresSafeArea())
            .navigationTitle("Parent Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .task {
                notificationStatus = await NotificationService.authorizationStatus()
            }
        }
    }
}

// MARK: - Sub-views

private struct StatCell: View {
    let value: String
    let label: String
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(KidSpark.Colors.spark)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct DashboardCard<Content: View>: View {
    let title: String
    let icon: String
    let accent: Color
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundStyle(accent)
                    .font(.system(size: 14, weight: .semibold))
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(accent)
            }
            content
        }
        .padding(16)
        .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
    }
}

private struct LanguageProgressRow: View {
    let language: Language
    let done: Int
    let total: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(language.displayName)
                    .font(.system(size: 13, weight: .semibold))
                Spacer()
                Text("\(done)/\(total)")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(.systemGray5)).frame(height: 6)
                    Capsule()
                        .fill(Color(hex: language.accentHex) ?? KidSpark.Colors.spark)
                        .frame(width: total > 0 ? geo.size.width * CGFloat(done) / CGFloat(total) : 0,
                               height: 6)
                }
            }
            .frame(height: 6)
        }
    }
}

private struct WeeklyBarChart: View {
    let data: [(String, Int)]

    private var maxCount: Int { data.map(\.1).max() ?? 1 }

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            ForEach(data, id: \.0) { day, count in
                VStack(spacing: 4) {
                    Spacer()
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(count > 0 ? KidSpark.Colors.spark : Color(.systemGray5))
                        .frame(height: max(6, CGFloat(count) / CGFloat(max(maxCount, 1)) * 56))
                    Text(day)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

private struct ConceptChip: View {
    let concept: Concept
    let count: Int

    var body: some View {
        HStack(spacing: 6) {
            Text(concept.emoji).font(.system(size: 14))
            Text(concept.displayName)
                .font(.system(size: 12, weight: .semibold))
            Text("×\(count)")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(KidSpark.Colors.coral.opacity(0.12), in: Capsule())
        .foregroundStyle(KidSpark.Colors.coral)
    }
}

/// Adaptive grid of concept chips. LazyVGrid is enough since we cap at 6.
private struct FlexibleChipGrid<Content: View>: View {
    let items: [(Concept, Int)]
    let spacing: CGFloat
    let content: (Concept, Int) -> Content

    init(items: [(Concept, Int)],
         spacing: CGFloat = 8,
         @ViewBuilder content: @escaping (Concept, Int) -> Content) {
        self.items = items
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 130), spacing: spacing, alignment: .leading)],
            alignment: .leading,
            spacing: spacing
        ) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, pair in
                content(pair.0, pair.1)
            }
        }
    }
}

private struct LanguageLessonDrillDown: View {
    let language: Language
    @Environment(AppState.self) private var appState

    private var lessons: [Lesson] { appState.catalog.lessons(for: language.id) }

    var body: some View {
        List {
            ForEach(lessons) { lesson in
                let p = appState.progressByID[lesson.id]
                HStack(spacing: 12) {
                    Image(systemName: icon(for: p?.status))
                        .foregroundStyle(color(for: p?.status))
                        .frame(width: 22)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(lesson.title)
                            .font(.system(size: 14, weight: .semibold))
                        Text(tierLabel(lesson.tier))
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if let p, p.status == .completed {
                        Text("Best \(p.bestScore)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle(language.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func icon(for status: NodeStatus?) -> String {
        switch status {
        case .completed: return "checkmark.circle.fill"
        case .inProgress: return "circle.dotted"
        case .available: return "circle"
        case .proLocked: return "crown.fill"
        case .locked, .none: return "lock.fill"
        }
    }

    private func color(for status: NodeStatus?) -> Color {
        switch status {
        case .completed: return KidSpark.Colors.leaf
        case .inProgress: return KidSpark.Colors.spark
        case .available: return KidSpark.Colors.sky
        case .proLocked: return KidSpark.Colors.glow
        case .locked, .none: return .secondary
        }
    }

    private func tierLabel(_ tier: LessonTier) -> String {
        switch tier {
        case .basics: return "Basics"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        }
    }
}

private struct DailyGoalStepper: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(appState.learner.dailyGoal) lesson\(appState.learner.dailyGoal == 1 ? "" : "s") / day")
                    .font(.system(size: 15, weight: .bold))
                Text("Target for streak to count")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Stepper(
                "Daily goal",
                value: Binding(
                    get: { appState.learner.dailyGoal },
                    set: { appState.setDailyGoal($0) }
                ),
                in: 1...10
            )
            .labelsHidden()
        }
    }
}

private struct CircleProgress: View {
    let fraction: Double
    let color: Color

    var body: some View {
        ZStack {
            Circle().stroke(Color(.systemGray5), lineWidth: 5)
            Circle()
                .trim(from: 0, to: fraction)
                .stroke(color, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int(fraction * 100))%")
                .font(.system(size: 11, weight: .bold))
        }
    }
}
