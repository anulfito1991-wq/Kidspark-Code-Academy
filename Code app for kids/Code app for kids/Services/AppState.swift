import Foundation
import SwiftData
import Observation

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
        catalog.loadIfNeeded()
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
        return UnlockService.status(
            for: lesson,
            previousLessonInSamePath: previous,
            progressByID: progressByID,
            hasPro: hasPro
        )
    }

    func markOpened(_ lesson: Lesson) {
        let progress = ensureProgress(for: lesson)
        if progress.status == .available {
            progress.status = .inProgress
        }
        progress.lastOpenedAt = .now
        progressByID[lesson.id] = progress
        try? modelContext.save()
    }

    func completeLesson(_ lesson: Lesson, score: Int) {
        let progress = ensureProgress(for: lesson)
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

    private func ensureProgress(for lesson: Lesson) -> LessonProgress {
        if let existing = progressByID[lesson.id] {
            return existing
        }
        let new = LessonProgress(lessonID: lesson.id, languageID: lesson.languageID, status: .available)
        modelContext.insert(new)
        progressByID[lesson.id] = new
        return new
    }

    private func reloadProgressIndex() {
        let descriptor = FetchDescriptor<LessonProgress>()
        let all = (try? modelContext.fetch(descriptor)) ?? []
        progressByID = Dictionary(uniqueKeysWithValues: all.map { ($0.lessonID, $0) })
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
        NotificationService.cancelAll()
        try? modelContext.save()
    }

    private static func loadOrCreateLearner(in context: ModelContext) -> Learner {
        let descriptor = FetchDescriptor<Learner>()
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        let fresh = Learner()
        context.insert(fresh)
        try? context.save()
        return fresh
    }
}
