import Foundation
import UserNotifications

@MainActor
enum NotificationService {
    static func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        if settings.authorizationStatus == .notDetermined {
            return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        }
        return settings.authorizationStatus == .authorized
    }

    // Schedules a streak reminder for 6 PM today; replaces any existing one.
    static func scheduleStreakReminder(streakDays: Int) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["streak_reminder"])

        var comps = Calendar.current.dateComponents([.year, .month, .day], from: .now)
        comps.hour = 18
        comps.minute = 0
        comps.second = 0
        guard let fireDate = Calendar.current.date(from: comps),
              fireDate > .now else { return }

        let content = UNMutableNotificationContent()
        content.title = "🔥 Your streak is waiting!"
        content.body = "Keep your \(streakDays)-day streak alive — it only takes 2 minutes!"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: comps, repeats: false)
        let request = UNNotificationRequest(
            identifier: "streak_reminder", content: content, trigger: trigger)
        center.add(request)
    }

    // Schedules a new-challenge alert for next Monday at 9 AM.
    static func scheduleWeeklyChallengeAlert() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["weekly_challenge"])

        var comps = DateComponents()
        comps.weekday = 2   // Monday (Gregorian; Sun=1)
        comps.hour = 9
        comps.minute = 0
        comps.second = 0

        let content = UNMutableNotificationContent()
        content.title = "⚡ New Challenge Unlocked!"
        content.body = "This week's coding challenge is live. Can you beat it?"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: comps, repeats: true)
        let request = UNNotificationRequest(
            identifier: "weekly_challenge", content: content, trigger: trigger)
        center.add(request)
    }

    // Posts a local notification immediately (used for milestone celebrations).
    static func postMilestoneNotification(headline: String, message: String) {
        let content = UNMutableNotificationContent()
        content.title = "🎉 \(headline)"
        content.body = message
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let id = "milestone_\(UUID().uuidString)"
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    static func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    static func isAuthorized() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus == .authorized
    }
}
