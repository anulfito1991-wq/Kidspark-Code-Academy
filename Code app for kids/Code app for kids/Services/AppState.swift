import Foundation
import SwiftData
import Observation
import OSLog

private let appStateLog = Logger(subsystem: "com.kidspark.academy", category: "AppState")

@Observable
@MainActor
final class AppState {
    let catalog: CatalogStore
    let store: StoreService
    private(set) var learner: Learner
    private(set) var progressByID: [String: LessonProgress] = [:]
    private(set) var recentlyEarnedBadges: [Badge] = []
    private(set) var currentMilestone: XPMilestone?
    private(set) var activeChallenge: ChallengeEntry?
    /// Surfaces the last SwiftData fetch error (if any) so UI / diagnostics
    /// can tell a cold "no progress yet" state apart from a load failure.
    private(set) var lastFetchError: String?
    var showLevelUp: Bool = false
    var lastAwardedXP: Int = 0

    private let modelContext: ModelContext

    init(modelContext: ModelContext, catalog: CatalogStore, store: StoreService) {
        self.modelContext = modelContext
        self.catalog = catalog
        self.store = store
        self.learner = Self.loadOrCreateLearner(in: modelContext)
        reloadProgressIndex()
    }

    func bootstrap() async {
        await catalog.loadIfNeeded()
        await store.start()
        syncProFromStore()
        loadActiveChallenge()
    }

    private func loadActiveChallenge() {
        let entries = ChallengeService.loadEntries()
        activeChallenge = ChallengeService.activeEntry(from: entries)
    }

    func completeChallenge(_ entry: ChallengeEntry) {
        let weekID = ChallengeService.weekID()
        guard !ChallengeService.hasCompleted(weekID: weekID,
                                             completedIDs: learner.completedChallengeIDs) else { return }
        learner.completedChallengeIDs.append(ChallengeService.storageKey(for: weekID))
        awardXP(entry.xpReward)
        evaluateBadges()
        NotificationService.scheduleWeeklyChallengeAlert()
        try? modelContext.save()
    }

    func setDailyGoal(_ value: Int) {
        let clamped = max(1, min(10, value))
        guard learner.dailyGoal != clamped else { return }
        learner.dailyGoal = clamped
        try? modelContext.save()
    }

    func completeAgeGate(isUnder13: Bool, parentConsent: Bool = false) {
        learner.isUnder13 = isUnder13
        learner.ageGateCompleted = true
        // Record parent consent date only when a parent explicitly confirmed
        // on the under-13 path. 13+ users don't need parental consent.
        if parentConsent {
            learner.parentConsentDate = .now
        }
        try? modelContext.save()
    }

    func isChallengeCompleted() -> Bool {
        ChallengeService.hasCompleted(weekID: ChallengeService.weekID(),
                                      completedIDs: learner.completedChallengeIDs)
    }

    func syncProFromStore() {
        if learner.hasProCached != store.hasPro {
            learner.hasProCached = store.hasPro
            try? modelContext.save()
        }
    }

    var hasPro: Bool { store.hasPro || learner.hasProCached }

    func progress(for lessonID: String) -> LessonProgress? {
        progressByID[lessonID]
    }

    func status(for lesson: Lesson, in lessons: [Lesson]) -> NodeStatus {
        let previous = lessons
            .filter { $0.order < lesson.order }
            .sorted { $0.order < $1.order }
            .last
        let freeID = UnlockService.freeIntermediateLessonID(in: lessons, hasPro: hasPro)
        return UnlockService.status(
            for: lesson,
            previousLessonInSamePath: previous,
            progressByID: progressByID,
            hasPro: hasPro,
            freeIntermediateLessonID: freeID
        )
    }

    func markOpened(_ lesson: Lesson) {
        let (progress, didCreate) = ensureProgress(for: lesson)
        var needsSave = didCreate

        if progress.status == .available {
            progress.status = .inProgress
            needsSave = true
        }
        progress.lastOpenedAt = .now
        progressByID[lesson.id] = progress

        if needsSave {
            try? modelContext.save()
        }
    }

    func completeLesson(_ lesson: Lesson, score: Int) {
        let (progress, _) = ensureProgress(for: lesson)
        let alreadyCompleted = progress.status == .completed
        progress.status = .completed
        progress.bestScore = max(progress.bestScore, score)
        progress.attempts += 1
        progress.completedAt = .now
        progressByID[lesson.id] = progress

        if !alreadyCompleted {
            awardXP(lesson.xpReward)
            updateStreak()
            NotificationService.scheduleStreakReminder(streakDays: learner.streakDays)
        } else {
            lastAwardedXP = 0
        }

        evaluateBadges()
        try? modelContext.save()
    }

    private func awardXP(_ amount: Int) {
        let oldXP = learner.xp
        let oldLevel = XPService.level(for: oldXP)
        learner.xp += amount
        lastAwardedXP = amount
        let newLevel = XPService.level(for: learner.xp)
        if newLevel > oldLevel { showLevelUp = true }

        let shownIDs = Set(learner.earnedBadgeIDs)
        if let milestone = XPMilestoneService.milestone(oldXP: oldXP, newXP: learner.xp, shownIDs: shownIDs) {
            currentMilestone = milestone
            learner.earnedBadgeIDs.append(XPMilestoneService.storageKey(for: milestone))
        }
    }

    private func updateStreak() {
        let update = StreakService.touch(
            currentStreak: learner.streakDays,
            lastActive: learner.lastActiveDate,
            freezes: learner.streakFreezes
        )
        if StreakService.shouldConsumeFreeze(lastActive: learner.lastActiveDate), learner.streakFreezes > 0 {
            learner.streakFreezes -= 1
        }
        learner.streakDays = update.newStreak
        learner.lastActiveDate = .now
    }

    private func evaluateBadges() {
        let completedCount = progressByID.values.filter { $0.status == .completed }.count
        let ctx = BadgeService.EvaluationContext(
            xp: learner.xp,
            streakDays: learner.streakDays,
            completedLessonCount: completedCount,
            lessonsByLanguage: catalog.lessonsByLanguage,
            progressByID: progressByID
        )
        let earned = BadgeService.newlyEarned(alreadyEarned: Set(learner.earnedBadgeIDs), context: ctx)
        if !earned.isEmpty {
            learner.earnedBadgeIDs.append(contentsOf: earned.map(\.id))
            recentlyEarnedBadges = earned
        } else {
            recentlyEarnedBadges = []
        }
    }

    private func ensureProgress(for lesson: Lesson) -> (progress: LessonProgress, didCreate: Bool) {
        if let existing = progressByID[lesson.id] {
            return (existing, false)
        }
        let new = LessonProgress(lessonID: lesson.id, languageID: lesson.languageID, status: .available)
        modelContext.insert(new)
        progressByID[lesson.id] = new
        return (new, true)
    }

    private func reloadProgressIndex() {
        let descriptor = FetchDescriptor<LessonProgress>()
        do {
            let all = try modelContext.fetch(descriptor)
            progressByID = Dictionary(uniqueKeysWithValues: all.map { ($0.lessonID, $0) })
            lastFetchError = nil
        } catch {
            // Don't silently drop progress on a fetch failure — that makes
            // every lesson look locked. Log and expose the error so the bug
            // is diagnosable instead of invisible.
            appStateLog.error("LessonProgress fetch failed: \(error.localizedDescription, privacy: .public)")
            lastFetchError = error.localizedDescription
            // Preserve the current in-memory index; better to show stale than empty.
        }
    }

    func resetProgress() {
        for p in progressByID.values {
            modelContext.delete(p)
        }
        progressByID.removeAll()
        learner.xp = 0
        learner.streakDays = 0
        learner.lastActiveDate = nil
        learner.earnedBadgeIDs = []
        learner.completedChallengeIDs = []
        learner.ageGateCompleted = false
        learner.isUnder13 = false
        learner.parentConsentDate = nil
        NotificationService.cancelAll()
        ParentPINStore.clear()
        try? modelContext.save()
    }

    private static func loadOrCreateLearner(in context: ModelContext) -> Learner {
        let descriptor = FetchDescriptor<Learner>()
        do {
            if let existing = try context.fetch(descriptor).first {
                return existing
            }
        } catch {
            appStateLog.error("Learner fetch failed: \(error.localizedDescription, privacy: .public)")
        }
        let fresh = Learner()
        context.insert(fresh)
        do {
            try context.save()
        } catch {
            appStateLog.error("Learner save failed: \(error.localizedDescription, privacy: .public)")
        }
        return fresh
    }
}
