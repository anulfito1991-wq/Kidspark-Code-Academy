import SwiftUI

struct CodeFillStepView: View {
    let step: CodeFillStep
    let accent: Color
    let onSubmit: (_ correct: Bool) -> Void

    @State private var selected: Int?
    @State private var showResult: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Fill the blank")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            Text(step.prompt)
                .font(.title2.bold())

            codeLine
                .padding()
                .background(Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))

            Text("Pick the right piece:")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            FlowLayout(spacing: 10) {
                ForEach(Array(step.choices.enumerated()), id: \.offset) { index, choice in
                    chip(index: index, text: choice)
                }
            }

            if showResult, let s = selected {
                feedback(correct: s == step.correctIndex)
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

    private var codeLine: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(step.codeBefore)
                .font(.system(.body, design: .monospaced))
            Text(selected.map { step.choices[$0] } ?? "___")
                .font(.system(.body, design: .monospaced).bold())
                .foregroundStyle(selected == nil ? Color.secondary : accent)
            Text(step.codeAfter)
                .font(.system(.body, design: .monospaced))
            Spacer(minLength: 0)
        }
    }

    private func chip(index: Int, text: String) -> some View {
        Button {
            guard !showResult else { return }
            selected = index
        } label: {
            Text(text)
                .font(.system(.body, design: .monospaced).bold())
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(chipBackground(for: index), in: Capsule())
                .overlay(
                    Capsule().stroke(chipBorder(for: index), lineWidth: 2)
                )
                .foregroundStyle(.primary)
        }
        .buttonStyle(.plain)
    }

    private func chipBackground(for index: Int) -> Color {
        if showResult {
            if index == step.correctIndex { return .green.opacity(0.15) }
            if index == selected { return .red.opacity(0.15) }
        } else if index == selected {
            return accent.opacity(0.15)
        }
        return Color.secondary.opacity(0.08)
    }

    private func chipBorder(for index: Int) -> Color {
        if showResult {
            if index == step.correctIndex { return .green }
            if index == selected { return .red }
            return .clear
        }
        return index == selected ? accent : .clear
    }

    private func feedback(correct: Bool) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: correct ? "sparkles" : "lightbulb")
                .foregroundStyle(correct ? .green : .orange)
            VStack(alignment: .leading, spacing: 4) {
                Text(correct ? "Great job!" : "Almost.")
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

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if rowWidth + size.width > maxWidth {
                totalHeight += rowHeight + spacing
                totalWidth = max(totalWidth, rowWidth - spacing)
                rowWidth = 0
                rowHeight = 0
            }
            rowWidth += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        totalHeight += rowHeight
        totalWidth = max(totalWidth, rowWidth - spacing)
        return CGSize(width: totalWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let maxWidth = bounds.width
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
        var rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.minX + maxWidth {
                y += rowHeight + spacing
                x = bounds.minX
                rowHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
