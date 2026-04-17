import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    // Apple Kids Category (guideline 1.3) requires a parental gate before any
    // purchase flow. The gate must be something a young child is unlikely to
    // do by accident — Apple specifically disallows secure auth like a PIN.
    // A 3-second press-and-hold satisfies the "not easily accessible" bar.
    @State private var gatePassed: Bool = false

    private var store: StoreService { appState.store }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                KidSpark.Colors.pageBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        hero
                        if hasCompletedFreeTaste { lossAversionBanner }
                        featureList
                        comparisonTable
                        productButtons
                            .allowsHitTesting(gatePassed)
                            .opacity(gatePassed ? 1 : 0.35)
                        restoreButton
                            .allowsHitTesting(gatePassed)
                            .opacity(gatePassed ? 1 : 0.35)
                        if !gatePassed {
                            ParentalGate(gatePassed: $gatePassed)
                        }
                        trustBlock
                        disclosureBlock
                        legalLinks
                    }
                    .padding(KidSpark.Layout.pagePadding)
                }
            }
            .navigationTitle("Go Pro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .font(KidSpark.Fonts.callout)
                }
            }
            .task { await store.start() }
            .onChange(of: store.hasPro) { _, newValue in
                if newValue { appState.syncProFromStore(); dismiss() }
            }
            // Re-arm the gate every time the paywall re-appears so a child
            // can't just leave it unlocked.
            .onDisappear { gatePassed = false }
        }
    }

    // MARK: Freemium taste state

    /// True once the learner has finished at least one of the free "taste"
    /// intermediate lessons offered per language. Drives the loss-aversion
    /// banner: "You've already completed a Pro lesson — unlock the rest!"
    private var hasCompletedFreeTaste: Bool {
        guard !appState.hasPro else { return false }
        for lang in appState.catalog.languages {
            let lessons = appState.catalog.lessons(for: lang.id)
            guard let freeID = UnlockService.freeIntermediateLessonID(in: lessons, hasPro: false) else { continue }
            if appState.progressByID[freeID]?.status == .completed {
                return true
            }
        }
        return false
    }

    private var lossAversionBanner: some View {
        HStack(spacing: 12) {
            Text("🎉").font(.system(size: 28))
            VStack(alignment: .leading, spacing: 2) {
                Text("Great work!")
                    .font(KidSpark.Fonts.headline)
                Text("You've already completed a Pro lesson — unlock the rest!")
                    .font(KidSpark.Fonts.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(KidSpark.Colors.glow.opacity(0.15))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(KidSpark.Colors.glow.opacity(0.45), lineWidth: 1)
        )
    }

    // MARK: Hero

    private var hero: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous)
                .fill(LinearGradient(
                    colors: [KidSpark.Colors.spark, Color(hex: "#A855F7")!],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))

            // Decorative
            Circle()
                .fill(.white.opacity(0.08))
                .frame(width: 120, height: 120)
                .offset(x: 130, y: -30)

            VStack(spacing: 14) {
                Text("👑")
                    .font(.system(size: 64))
                Text("Unlock the full journey")
                    .font(KidSpark.Fonts.title2)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                Text("Every lesson. Every language. Every challenge.\nDouble XP, streak freezes, and first access\nto everything new we build.")
                    .font(KidSpark.Fonts.callout)
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
            }
            .padding(24)
        }
    }

    // MARK: Features

    private var featureList: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What Pro unlocks")
                .font(KidSpark.Fonts.headline)
                .padding(.bottom, 2)

            featureRow(
                emoji: "🚀",
                title: "All Intermediate lessons",
                detail: "Unlock deeper lessons across Swift, Python, JavaScript, and Scratch — plus every new Intermediate and Advanced lesson we add."
            )
            featureRow(
                emoji: "🌍",
                title: "Every language, fully open",
                detail: "Swift, Python, JavaScript, Java, Lua, HTML, and Scratch — explore one deeply or sample them all. No locked paths."
            )
            featureRow(
                emoji: "⚡",
                title: "Double XP on every lesson",
                detail: "Pro learners earn 2× XP on every completed lesson. Level up faster, unlock milestones sooner, and fill out the badge shelf."
            )
            featureRow(
                emoji: "❄️",
                title: "Streak freezes — 2 every month",
                detail: "Automatically receive 2 streak freezes at the start of every calendar month (up to 4 in reserve). One busy day won't break your streak."
            )
            featureRow(
                emoji: "✨",
                title: "First in line for new content",
                detail: "New lessons, new languages, and new features roll out to Pro learners first. Your learner is always at the front of the line."
            )
        }
        .kidSparkCard()
    }

    private func featureRow(emoji: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(emoji)
                .font(.system(size: 28))
                .frame(width: 36)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(KidSpark.Fonts.callout.weight(.bold))
                Text(detail)
                    .font(KidSpark.Fonts.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
    }

    // MARK: Comparison table

    private var comparisonTable: some View {
        VStack(spacing: 0) {
            // Header row
            HStack(spacing: 0) {
                Text("")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Free")
                    .font(KidSpark.Fonts.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .frame(width: 64)
                Text("Pro")
                    .font(KidSpark.Fonts.caption.weight(.bold))
                    .foregroundStyle(KidSpark.Colors.spark)
                    .frame(width: 64)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))

            comparisonRow("Basics lessons (42 total)",        free: "✓",     pro: "✓")
            comparisonRow("Intermediate lessons",              free: "1 taste", pro: "All")
            comparisonRow("Advanced lessons",                  free: "—",     pro: "All")
            comparisonRow("Weekly challenges",                 free: "✓",    pro: "✓")
            comparisonRow("XP earning rate",                   free: "1×",   pro: "2×")
            comparisonRow("Streak freezes",                    free: "—",    pro: "2/month")
            comparisonRow("Parent Dashboard",                  free: "✓",    pro: "✓")
            comparisonRow("Daily goals & reminders",           free: "✓",    pro: "✓")
            comparisonRow("Ads",                               free: "Never", pro: "Never", isLast: true)
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func comparisonRow(_ label: String, free: String, pro: String, isLast: Bool = false) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text(label)
                    .font(KidSpark.Fonts.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(free)
                    .font(KidSpark.Fonts.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 64)
                Text(pro)
                    .font(KidSpark.Fonts.caption.weight(.bold))
                    .foregroundStyle(KidSpark.Colors.spark)
                    .frame(width: 64)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            if !isLast {
                Divider().padding(.leading, 16)
            }
        }
    }

    // MARK: Trust block

    private var trustBlock: some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                trustPill(icon: "xmark.circle.fill", text: "No ads")
                trustPill(icon: "eye.slash.fill", text: "No tracking")
                trustPill(icon: "arrow.uturn.backward.circle.fill", text: "Cancel anytime")
            }
            Text("Progress and badges stay yours forever — even if you cancel.")
                .font(KidSpark.Fonts.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 4)
    }

    private func trustPill(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
            Text(text)
                .font(.system(size: 12, weight: .semibold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .foregroundStyle(KidSpark.Colors.spark)
        .background(KidSpark.Colors.spark.opacity(0.1), in: Capsule())
    }

    // MARK: Products

    @ViewBuilder
    private var productButtons: some View {
        if store.products.isEmpty {
            VStack(spacing: 8) {
                ProgressView()
                Text("Loading plans…")
                    .font(KidSpark.Fonts.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
        } else {
            VStack(spacing: 12) {
                ForEach(Array(store.products.enumerated()), id: \.element.id) { index, product in
                    Button {
                        Task { await store.purchase(product) }
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Text(product.displayName)
                                        .font(KidSpark.Fonts.headline)
                                    if index == store.products.count - 1 {
                                        Text("BEST VALUE")
                                            .font(KidSpark.Fonts.caption2)
                                            .padding(.horizontal, 6).padding(.vertical, 2)
                                            .background(KidSpark.Colors.glow, in: Capsule())
                                            .foregroundStyle(.black)
                                    }
                                }
                                Text(product.description)
                                    .font(KidSpark.Fonts.caption)
                                    .foregroundStyle(.white.opacity(0.85))
                            }
                            Spacer()
                            Text(product.displayPrice)
                                .font(.system(size: 18, weight: .black, design: .rounded))
                        }
                        .padding(18)
                        .background(
                            LinearGradient(
                                colors: [KidSpark.Colors.spark, Color(hex: "#A855F7")!],
                                startPoint: .leading, endPoint: .trailing
                            ),
                            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                        )
                        .foregroundStyle(.white)
                        .shadow(color: KidSpark.Colors.spark.opacity(0.35), radius: 10, y: 4)
                    }
                    .disabled(store.purchaseInFlight)
                }
            }
        }
    }

    private var restoreButton: some View {
        Button {
            Task { await store.restore() }
        } label: {
            Text("Restore purchases")
                .font(KidSpark.Fonts.callout)
                .foregroundStyle(KidSpark.Colors.spark)
        }
    }

    // MARK: Disclosure + legal

    private var disclosureBlock: some View {
        VStack(spacing: 6) {
            if let monthly = store.products.first(where: { $0.id.contains("monthly") }) {
                Text("Monthly plan: \(monthly.displayPrice) per month, auto-renewing.")
                    .font(KidSpark.Fonts.caption2)
                    .foregroundStyle(.secondary)
            }
            if let annual = store.products.first(where: { $0.id.contains("annual") }) {
                Text("Annual plan: \(annual.displayPrice) per year, auto-renewing.")
                    .font(KidSpark.Fonts.caption2)
                    .foregroundStyle(.secondary)
            }
            Text("Payment is charged to your Apple ID at confirmation. Subscriptions auto-renew for the same period unless cancelled at least 24 hours before the end of the current period. Manage or cancel anytime in Settings > Apple ID > Subscriptions.")
                .font(KidSpark.Fonts.caption2)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
        .padding(.horizontal, 4)
    }

    private var legalLinks: some View {
        HStack(spacing: 20) {
            Link("Terms of Service",
                 destination: URL(string: "https://anulfito1991-wq.github.io/Kidspark-Code-Academy/terms.html")!)
            Text("·").foregroundStyle(.secondary)
            Link("Privacy Policy",
                 destination: URL(string: "https://anulfito1991-wq.github.io/Kidspark-Code-Academy/")!)
        }
        .font(KidSpark.Fonts.caption)
        .foregroundStyle(KidSpark.Colors.spark)
    }
}

// MARK: - Parental Gate

/// Press-and-hold gate shown before the subscription buttons become active.
/// Satisfies Apple guideline 1.3 for the Kids Category: a simple action
/// outside a young child's typical motor pattern (3 second sustained press)
/// rather than a secure PIN — Apple disallows secure auth as the gate.
private struct ParentalGate: View {
    @Binding var gatePassed: Bool
    @State private var progress: Double = 0   // 0…1
    @State private var holdTask: Task<Void, Never>?

    private let requiredDuration: TimeInterval = 3.0

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "hand.raised.fill")
                    .foregroundStyle(KidSpark.Colors.spark)
                Text("Adults only")
                    .font(KidSpark.Fonts.headline)
            }
            Text("Press and hold the star for 3 seconds to continue.")
                .font(KidSpark.Fonts.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            ZStack {
                Circle()
                    .fill(KidSpark.Colors.spark.opacity(0.12))
                    .frame(width: 92, height: 92)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(KidSpark.Colors.spark,
                            style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 92, height: 92)
                    .animation(.linear(duration: 0.05), value: progress)
                Image(systemName: "star.fill")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(KidSpark.Colors.spark)
            }
            .contentShape(Circle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in startHoldIfNeeded() }
                    .onEnded { _ in cancelHold() }
            )
            .accessibilityLabel("Parental gate — press and hold to continue")
            .accessibilityHint("Hold for three seconds to unlock subscription options")

            Text("\(Int(progress * 100))%")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(KidSpark.Colors.spark.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
    }

    private func startHoldIfNeeded() {
        guard holdTask == nil, !gatePassed else { return }
        let start = Date()
        holdTask = Task { @MainActor in
            while !Task.isCancelled {
                let elapsed = Date().timeIntervalSince(start)
                progress = min(1.0, elapsed / requiredDuration)
                if progress >= 1.0 {
                    // Light haptic and unlock
                    #if canImport(UIKit)
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    #endif
                    gatePassed = true
                    holdTask = nil
                    return
                }
                try? await Task.sleep(nanoseconds: 50_000_000) // 50 ms
            }
        }
    }

    private func cancelHold() {
        holdTask?.cancel()
        holdTask = nil
        if !gatePassed {
            withAnimation(.easeOut(duration: 0.2)) { progress = 0 }
        }
    }
}
