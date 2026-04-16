import SwiftUI
import UserNotifications

struct ProfileView: View {
    @Environment(AppState.self) private var appState
    @State private var confirmReset: Bool = false
    @State private var showPaywall: Bool = false
    @State private var notificationsEnabled: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section("You") {
                    let binding = Binding(
                        get: { appState.learner.displayName },
                        set: { appState.learner.displayName = $0 }
                    )
                    TextField("Name", text: binding)
                    HStack {
                        Label("Member since", systemImage: "calendar")
                        Spacer()
                        Text(appState.learner.createdAt, style: .date)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Subscription") {
                    HStack {
                        Label(appState.hasPro ? "Pro" : "Free", systemImage: appState.hasPro ? "crown.fill" : "person")
                        Spacer()
                        if !appState.hasPro {
                            Button("Upgrade") { showPaywall = true }
                                .buttonStyle(.borderedProminent)
                        }
                    }
                    Button("Restore purchases") {
                        Task { await appState.store.restore() }
                    }
                }

                Section("Notifications") {
                    Toggle(isOn: $notificationsEnabled) {
                        Label("Streak & challenge reminders", systemImage: "bell.fill")
                    }
                    .onChange(of: notificationsEnabled) { _, enabled in
                        if enabled {
                            Task {
                                let granted = await NotificationService.requestPermission()
                                if granted {
                                    NotificationService.scheduleStreakReminder(streakDays: appState.learner.streakDays)
                                    NotificationService.scheduleWeeklyChallengeAlert()
                                } else {
                                    notificationsEnabled = false
                                }
                            }
                        } else {
                            NotificationService.cancelAll()
                        }
                    }
                }

                Section("Data") {
                    Button(role: .destructive) {
                        confirmReset = true
                    } label: {
                        Label("Reset progress", systemImage: "arrow.counterclockwise")
                    }
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showPaywall) { PaywallView() }
            .task {
                notificationsEnabled = await NotificationService.isAuthorized()
            }
            .confirmationDialog(
                "Reset all progress?",
                isPresented: $confirmReset,
                titleVisibility: .visible
            ) {
                Button("Reset everything", role: .destructive) {
                    appState.resetProgress()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This clears your XP, streak, and completed lessons. Your Pro subscription is not affected.")
            }
        }
    }
}
