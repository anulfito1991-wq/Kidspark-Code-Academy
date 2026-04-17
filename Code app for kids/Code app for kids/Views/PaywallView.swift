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
                        productButtons
                            .allowsHitTesting(gatePassed)
                            .opacity(gatePassed ? 1 : 0.35)
                        restoreButton
                            .allowsHitTesting(gatePassed)
                            .opacity(gatePassed ? 1 : 0.35)
                        if !gatePassed {
                            ParentalGate(gatePassed: $gatePassed)
                        }
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
                Text("Open up Intermediate and Advanced lessons\nacross every language — forever.")
                    .font(KidSpark.Fonts.callout)
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
            }
            .padding(24)
        }
    }

    // MARK: Features

    private var featureList: some View {
        VStack(alignment: .leading, spacing: 14) {
            featureRow(emoji: "🚀", text: "All Intermediate & Advanced lessons")
            featureRow(emoji: "❄️", text: "Streak freezes so you never lose your streak")
            featureRow(emoji: "⚡", text: "Bonus XP on every lesson you complete")
            featureRow(emoji: "✨", text: "Priority access to new languages as they launch")
        }
        .kidSparkCard()
    }

    private func featureRow(emoji: String, text: String) -> some View {
        HStack(spacing: 12) {
            Text(emoji).font(.title2)
            Text(text)
                .font(KidSpark.Fonts.callout)
            Spacer()
        }
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
