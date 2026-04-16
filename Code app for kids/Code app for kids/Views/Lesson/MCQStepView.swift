import SwiftUI

struct MCQStepView: View {
    let step: MCQStep
    let accent: Color
    let onSubmit: (_ correct: Bool) -> Void

    @State private var selected: Int?
    @State private var showResult: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Quick check")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            Text(step.prompt)
                .font(.title2.bold())

            VStack(spacing: 12) {
                ForEach(Array(step.options.enumerated()), id: \.offset) { index, option in
                    choiceButton(index: index, text: option)
                }
            }

            if showResult, let s = selected {
                feedbackCard(correct: s == step.correctIndex)
            }

            Spacer()

            Button(action: submit) {
                Text(showResult ? "Continue" : "Check")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        (selected == nil ? Color.secondary.opacity(0.3) : accent),
                        in: Capsule()
                    )
                    .foregroundStyle(.white)
            }
            .disabled(selected == nil)
        }
        .padding()
    }

    private func choiceButton(index: Int, text: String) -> some View {
        Button {
            guard !showResult else { return }
            selected = index
        } label: {
            HStack {
                Text(text)
                    .font(.body)
                Spacer()
                if showResult, index == step.correctIndex {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                } else if showResult, index == selected {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.red)
                }
            }
            .padding()
            .background(background(for: index), in: RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(border(for: index), lineWidth: 2)
            )
            .foregroundStyle(.primary)
        }
        .buttonStyle(.plain)
    }

    private func background(for index: Int) -> Color {
        if showResult {
            if index == step.correctIndex { return .green.opacity(0.15) }
            if index == selected { return .red.opacity(0.15) }
        } else if index == selected {
            return accent.opacity(0.15)
        }
        return Color.secondary.opacity(0.08)
    }

    private func border(for index: Int) -> Color {
        if showResult {
            if index == step.correctIndex { return .green }
            if index == selected { return .red }
            return .clear
        }
        return index == selected ? accent : .clear
    }

    private func feedbackCard(correct: Bool) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: correct ? "sparkles" : "lightbulb")
                .foregroundStyle(correct ? .green : .orange)
            VStack(alignment: .leading, spacing: 4) {
                Text(correct ? "Nice!" : "Not quite.")
                    .font(.headline)
                if let explanation = step.explanation {
                    Text(explanation)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: 0)
        }
        .padding()
        .background((correct ? Color.green : Color.orange).opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
    }

    private func submit() {
        guard let s = selected else { return }
        if showResult {
            onSubmit(s == step.correctIndex)
        } else {
            withAnimation(.spring(response: 0.3)) {
                showResult = true
            }
        }
    }
}
