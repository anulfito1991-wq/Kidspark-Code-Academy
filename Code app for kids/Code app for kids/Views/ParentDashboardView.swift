import SwiftUI

struct ParentDashboardView: View {
    var body: some View {
        ParentPINGate {
            ParentDashboardContent()
        }
    }
}

private struct ParentDashboardContent: View {
    @Environment(AppState.self) private var appState

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
                            Text("Last active: \(last, style: .relative) ago")
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

                    // Language progress
                    DashboardCard(title: "Languages", icon: "list.bullet", accent: KidSpark.Colors.sky) {
                        VStack(spacing: 10) {
                            ForEach(languageProgress, id: \.0.id) { lang, done, total in
                                LanguageProgressRow(language: lang, done: done, total: total)
                            }
                        }
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
