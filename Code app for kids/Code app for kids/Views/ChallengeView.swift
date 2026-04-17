import SwiftUI

struct ChallengeView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    let entry: ChallengeEntry

    @State private var shuffledOptions: [String] = []
    @State private var selectedOption: String?
    @State private var showResult: Bool = false
    @State private var showConfetti: Bool = false

    private var isCorrect: Bool {
        selectedOption == entry.options.first
    }

    var body: some View {
        NavigationStack {
            ZStack {
                KidSpark.Colors.pageBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 6) {
                            HStack(spacing: 6) {
                                Image(systemName: "bolt.fill")
                                    .foregroundStyle(KidSpark.Colors.spark)
                                Text("WEEKLY CHALLENGE")
                                    .font(.system(size: 11, weight: .black))
                                    .foregroundStyle(KidSpark.Colors.spark)
                                    .tracking(1)
                            }
                            Text(entry.title)
                                .font(.system(size: 26, weight: .black))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 8)

                        // Prompt card
                        Text(entry.prompt)
                            .font(.system(size: 18, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .padding(20)
                            .frame(maxWidth: .infinity)
                            .background(.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .shadow(color: .black.opacity(0.06), radius: 8, y: 4)

                        // Answer options
                        VStack(spacing: 12) {
                            ForEach(shuffledOptions, id: \.self) { option in
                                OptionButton(
                                    label: option,
                                    state: optionState(for: option),
                                    isEnabled: selectedOption == nil
                                ) {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedOption = option
                                        showResult = true
                                        if option == entry.options.first {
                                            showConfetti = true
                                        }
                                    }
                                }
                            }
                        }

                        // Result feedback
                        if showResult {
                            ResultBanner(isCorrect: isCorrect, xpReward: entry.xpReward)
                                .transition(.move(edge: .bottom).combined(with: .opacity))

                            Button {
                                if isCorrect {
                                    appState.completeChallenge(entry)
                                }
                                dismiss()
                            } label: {
                                Text(isCorrect ? "Claim \(entry.xpReward) XP ⚡" : "Keep practicing!")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(isCorrect ? KidSpark.Colors.spark : KidSpark.Colors.coral,
                                                in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                            .transition(.opacity)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }

                if showConfetti {
                    ConfettiView(isActive: showConfetti)
                        .allowsHitTesting(false)
                        .ignoresSafeArea()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .onAppear {
            shuffledOptions = entry.options.shuffled()
        }
    }

    private func optionState(for option: String) -> OptionState {
        guard let selected = selectedOption else { return .idle }
        if option == entry.options.first { return .correct }
        if option == selected { return .wrong }
        return .idle
    }
}

private enum OptionState { case idle, correct, wrong }

private struct OptionButton: View {
    let label: String
    let state: OptionState
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(state == .idle ? Color.primary : .white)
                Spacer()
                if state != .idle {
                    Image(systemName: state == .correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(.white)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(background)
        }
        .disabled(!isEnabled)
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var background: some View {
        switch state {
        case .idle:
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.white)
                .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
        case .correct:
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(KidSpark.Colors.leaf)
        case .wrong:
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(KidSpark.Colors.coral)
        }
    }
}

private struct ResultBanner: View {
    let isCorrect: Bool
    let xpReward: Int

    var body: some View {
        VStack(spacing: 6) {
            Text(isCorrect ? "🎉 Correct!" : "😅 Not quite!")
                .font(.system(size: 22, weight: .black))
            Text(isCorrect
                 ? "You nailed it! +\(xpReward) XP incoming."
                 : "Good try — read the answer above and come back next week!")
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(isCorrect ? KidSpark.Colors.leaf.opacity(0.12) : KidSpark.Colors.coral.opacity(0.12))
        )
    }
}
