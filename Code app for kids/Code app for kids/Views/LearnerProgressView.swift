import SwiftUI

struct LearnerProgressView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                KidSpark.Colors.pageBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        xpCard
                        streakCard
                        badgesCard
                        languagesCard
                        Spacer(minLength: 20)
                    }
                    .padding(KidSpark.Layout.pagePadding)
                }
            }
            .navigationTitle("My Progress")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: XP card

    private var xpCard: some View {
        VStack(spacing: 14) {
            HStack {
                Label("Experience Points", systemImage: "bolt.fill")
                    .font(KidSpark.Fonts.headline)
                    .foregroundStyle(KidSpark.Colors.spark)
                Spacer()
                Text("Total: \(appState.learner.xp) XP")
                    .font(KidSpark.Fonts.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            XPBar(xp: appState.learner.xp)
        }
        .kidSparkCard()
    }

    // MARK: Streak card

    private var streakCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Streak", systemImage: "flame.fill")
                .font(KidSpark.Fonts.headline)
                .foregroundStyle(KidSpark.Colors.tangerine)
            HStack(spacing: 16) {
                StreakPill(days: appState.learner.streakDays)
                if appState.learner.streakFreezes > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "snowflake")
                            .foregroundStyle(KidSpark.Colors.sky)
                        Text("\(appState.learner.streakFreezes) freeze\(appState.learner.streakFreezes == 1 ? "" : "s")")
                            .font(KidSpark.Fonts.caption)
                    }
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(KidSpark.Colors.sky.opacity(0.12), in: Capsule())
                }
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .kidSparkCard()
    }

    // MARK: Badges card

    private var badgesCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Badges", systemImage: "rosette")
                    .font(KidSpark.Fonts.headline)
                    .foregroundStyle(KidSpark.Colors.coral)
                Spacer()
                Text("\(appState.learner.earnedBadgeIDs.filter { !$0.hasPrefix("milestone_") }.count)/\(BadgeCatalog.all.count)")
                    .font(KidSpark.Fonts.caption)
                    .foregroundStyle(.secondary)
            }
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 96), spacing: 12)],
                spacing: 14
            ) {
                ForEach(BadgeCatalog.all) { badge in
                    let earned = appState.learner.earnedBadgeIDs.contains(badge.id)
                    badgeTile(badge: badge, earned: earned)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .kidSparkCard()
    }

    private func badgeTile(badge: Badge, earned: Bool) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(earned ? badge.accent.opacity(0.15) : Color(.systemGray6))
                    .frame(width: 60, height: 60)
                if earned {
                    Circle()
                        .stroke(badge.accent.opacity(0.4), lineWidth: 2)
                        .frame(width: 60, height: 60)
                }
                Text(earned ? badge.emoji : "🔒")
                    .font(.system(size: 28))
                    .grayscale(earned ? 0 : 1)
                    .opacity(earned ? 1 : 0.4)
            }
            Text(earned ? badge.title.components(separatedBy: " ").dropLast().joined(separator: " ") : "Locked")
                .font(KidSpark.Fonts.caption2)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 84)
                .foregroundStyle(earned ? .primary : .secondary)
        }
    }

    // MARK: Languages card

    private var languagesCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Languages", systemImage: "globe")
                .font(KidSpark.Fonts.headline)
                .foregroundStyle(KidSpark.Colors.sky)
            ForEach(appState.catalog.languages) { lang in
                HStack(spacing: 14) {
                    Image(systemName: lang.iconSystemName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(lang.accent, in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(lang.displayName)
                            .font(KidSpark.Fonts.callout)
                        ProgressView(value: fraction(for: lang.id))
                            .tint(lang.accent)
                    }

                    Text("\(Int(fraction(for: lang.id) * 100))%")
                        .font(KidSpark.Fonts.caption)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                        .frame(width: 36, alignment: .trailing)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .kidSparkCard()
    }

    private func fraction(for languageID: String) -> Double {
        let basics = appState.catalog.lessons(for: languageID).filter { $0.tier == .basics }
        guard !basics.isEmpty else { return 0 }
        let done = basics.filter { appState.progress(for: $0.id)?.status == .completed }.count
        return Double(done) / Double(basics.count)
    }
}
