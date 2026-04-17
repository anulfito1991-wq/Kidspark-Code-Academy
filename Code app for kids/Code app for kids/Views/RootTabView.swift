import SwiftUI
import SwiftData

struct RootTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var appState: AppState?
    @State private var catalog = CatalogStore()
    @State private var store = StoreService()
    @State private var selectedTab: Int = 0

    var body: some View {
        Group {
            if let appState {
                ZStack {
                    if !appState.learner.ageGateCompleted {
                        AgeGateView()
                            .environment(appState)
                            .transition(.opacity)
                    } else {
                        TabView(selection: $selectedTab) {
                            HomeView()
                                .tag(0)
                                .tabItem { Label("Learn", systemImage: "bolt.fill") }
                            LearnerProgressView()
                                .tag(1)
                                .tabItem { Label("Progress", systemImage: "chart.bar.fill") }
                            PaywallView()
                                .tag(2)
                                .tabItem { Label("Pro", systemImage: "crown.fill") }
                            ProfileView()
                                .tag(3)
                                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
                            ParentDashboardView()
                                .tag(4)
                                .tabItem { Label("Parents", systemImage: "person.2.fill") }
                        }
                        .tint(KidSpark.Colors.spark)
                        .environment(appState)
                        .task {
                            await appState.bootstrap()
                            // Notification permission is NOT requested at
                            // bootstrap. For Kids Category compliance it must
                            // be initiated explicitly by a parent via the
                            // Parent Dashboard "Enable reminders" control.
                        }
                    }

                    // Level-up toast
                    if appState.showLevelUp {
                        LevelUpToast(level: XPService.level(for: appState.learner.xp)) {
                            appState.showLevelUp = false
                        }
                        .zIndex(10)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.spring(response: 0.4), value: appState.showLevelUp)
                    }
                }
            } else {
                splashScreen
                    .onAppear { bootstrap() }
            }
        }
    }

    // MARK: Splash / loading

    private var splashScreen: some View {
        ZStack {
            KidSpark.Colors.heroGradient.ignoresSafeArea()
            VStack(spacing: 20) {
                KidSpark.LogoMark(size: 90)
                    .shadow(color: .black.opacity(0.2), radius: 20, y: 8)
                VStack(spacing: 4) {
                    Text("KidSpark")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Academy")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                }
                ProgressView()
                    .tint(.white.opacity(0.7))
                    .padding(.top, 12)
            }
        }
    }

    private func bootstrap() {
        // Catalog loads asynchronously inside AppState.bootstrap() so we don't
        // block the main thread here.
        appState = AppState(modelContext: modelContext, catalog: catalog, store: store)
    }
}

// MARK: - Level-up toast

private struct LevelUpToast: View {
    let level: Int
    let onDismiss: () -> Void

    @State private var appear: Bool = false

    var body: some View {
        VStack {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(KidSpark.Colors.heroGradient)
                        .frame(width: 44, height: 44)
                    Text("⭐")
                        .font(.system(size: 22))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Level Up!")
                        .font(KidSpark.Fonts.headline)
                        .foregroundStyle(.white)
                    Text("You reached Level \(level) — incredible! 🎉")
                        .font(KidSpark.Fonts.caption)
                        .foregroundStyle(.white.opacity(0.9))
                }
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .padding(16)
            .background(KidSpark.Colors.heroGradient, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: KidSpark.Colors.spark.opacity(0.4), radius: 16, y: 6)
            .padding(.horizontal, 16)
            .padding(.top, 56)
            Spacer()
        }
        .scaleEffect(appear ? 1.0 : 0.85)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) { appear = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation { onDismiss() }
            }
        }
    }
}
