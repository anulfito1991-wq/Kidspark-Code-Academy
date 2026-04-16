import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    private var store: StoreService { appState.store }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                KidSpark.Colors.pageBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        hero
                        featureList
                        productButtons
                        restoreButton
                        Text("Subscriptions auto-renew until cancelled. Manage or cancel anytime in Settings.")
                            .font(KidSpark.Fonts.caption)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
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
        }
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
}
