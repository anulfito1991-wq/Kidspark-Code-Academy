import Foundation

struct XPMilestone: Identifiable, Sendable {
    let id: String          // stored in learner.earnedBadgeIDs as "milestone_<id>"
    let threshold: Int
    let emoji: String
    let headline: String
    let message: String
    let coachTip: String    // retention nudge
    let accentKey: String   // "spark" | "glow" | "coral" | "leaf" | "sky"
}

enum XPMilestoneService {
    static let all: [XPMilestone] = [
        XPMilestone(
            id: "xp_25",
            threshold: 25,
            emoji: "🌱",
            headline: "You're growing!",
            message: "Your very first sparks are lighting up. Every coder started exactly where you are right now.",
            coachTip: "Come back tomorrow and watch yourself get even better!",
            accentKey: "leaf"
        ),
        XPMilestone(
            id: "xp_50",
            threshold: 50,
            emoji: "🔥",
            headline: "You're on fire!",
            message: "50 XP already? You're building a real habit. Habits are how great coders are made.",
            coachTip: "A little bit every day adds up to something amazing — see you tomorrow!",
            accentKey: "tangerine"
        ),
        XPMilestone(
            id: "xp_100",
            threshold: 100,
            emoji: "⭐",
            headline: "Level 2 Coder!",
            message: "Your brain literally grew stronger today. Scientists call it neuroplasticity — you call it being awesome.",
            coachTip: "The best part? It only gets more fun from here. Keep it going!",
            accentKey: "glow"
        ),
        XPMilestone(
            id: "xp_150",
            threshold: 150,
            emoji: "🚀",
            headline: "Blast off!",
            message: "150 XP — you're not just a learner, you're an explorer. Coding is about discovering things no one has ever made before.",
            coachTip: "Real coders learn every day. You've already got the habit — amazing!",
            accentKey: "sky"
        ),
        XPMilestone(
            id: "xp_200",
            threshold: 200,
            emoji: "💪",
            headline: "You can do hard things!",
            message: "200 XP! You've proven that when something is tricky, you stick with it. That's the #1 skill in coding.",
            coachTip: "Your streak is a superpower. Keep showing up!",
            accentKey: "coral"
        ),
        XPMilestone(
            id: "xp_300",
            threshold: 300,
            emoji: "🎯",
            headline: "Unstoppable!",
            message: "300 XP! Three levels in. The things you're learning now are the same foundations every professional developer started with.",
            coachTip: "One more lesson and you'll be even closer to the next badge. You've got this!",
            accentKey: "spark"
        ),
        XPMilestone(
            id: "xp_500",
            threshold: 500,
            emoji: "✨",
            headline: "Spark Champion!",
            message: "500 XP! You are officially a KidSpark Academy coder. Not just learning — you're growing into someone who builds things.",
            coachTip: "You've built something real — a learning habit. That's more valuable than any app.",
            accentKey: "spark"
        ),
        XPMilestone(
            id: "xp_750",
            threshold: 750,
            emoji: "🏆",
            headline: "Elite Learner!",
            message: "750 XP! Most people give up before getting here. You didn't. Remember that feeling.",
            coachTip: "You're in rare company now — keep showing up and see where this takes you!",
            accentKey: "glow"
        ),
        XPMilestone(
            id: "xp_1000",
            threshold: 1000,
            emoji: "🌟",
            headline: "1000 XP Superstar!",
            message: "ONE THOUSAND XP! You are a KidSpark Legend. Seriously — this is a big deal. Share this with someone who made you feel proud today.",
            coachTip: "Keep going — the next chapter is waiting for you!",
            accentKey: "coral"
        )
    ]

    /// Returns the first milestone crossed when XP moves from `oldXP` to `newXP`
    /// that hasn't already been shown (tracked by storedIDs with "milestone_" prefix).
    static func milestone(
        oldXP: Int,
        newXP: Int,
        shownIDs: Set<String>
    ) -> XPMilestone? {
        all.first { m in
            m.threshold > oldXP &&
            m.threshold <= newXP &&
            !shownIDs.contains("milestone_\(m.id)")
        }
    }

    static func storageKey(for milestone: XPMilestone) -> String {
        "milestone_\(milestone.id)"
    }
}
