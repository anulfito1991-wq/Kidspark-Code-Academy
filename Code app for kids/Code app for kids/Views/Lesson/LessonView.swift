import SwiftUI

struct LessonView: View {
    let lesson: Lesson
    let language: Language

    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var stepIndex: Int = 0
    @State private var correctCount: Int = 0
    @State private var checkCount: Int = 0
    @State private var showReward: Bool = false

    var body: some View {
        Group {
            if showReward {
                RewardStepView(
                    xp: lesson.xpReward,
                    accent: language.accent,
                    earnedBadges: appState.recentlyEarnedBadges,
                    milestone: appState.currentMilestone,
                    onContinue: { dismiss() }
                )
            } else {
                stepContent
            }
        }
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text(lesson.title).font(.headline)
                    ProgressView(value: progressFraction)
                        .tint(language.accent)
                        .frame(width: 140)
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") { dismiss() }
            }
        }
        .onAppear {
            appState.markOpened(lesson)
        }
    }

    private var progressFraction: Double {
        guard !lesson.steps.isEmpty else { return 0 }
        return Double(stepIndex) / Double(lesson.steps.count)
    }

    @ViewBuilder
    private var stepContent: some View {
        if stepIndex < lesson.steps.count {
            switch lesson.steps[stepIndex] {
            case .explainer(let s):
                ExplainerStepView(step: s, accent: language.accent) {
                    advance()
                }
            case .mcq(let s):
                MCQStepView(step: s, accent: language.accent) { correct in
                    checkCount += 1
                    if correct { correctCount += 1 }
                    advance()
                }
            case .codeFill(let s):
                CodeFillStepView(step: s, accent: language.accent) { correct in
                    checkCount += 1
                    if correct { correctCount += 1 }
                    advance()
                }
            }
        }
    }

    private func advance() {
        if stepIndex + 1 >= lesson.steps.count {
            let score = checkCount == 0 ? 100 : Int(Double(correctCount) / Double(checkCount) * 100)
            appState.completeLesson(lesson, score: score)
            withAnimation { showReward = true }
        } else {
            withAnimation { stepIndex += 1 }
        }
    }
}
