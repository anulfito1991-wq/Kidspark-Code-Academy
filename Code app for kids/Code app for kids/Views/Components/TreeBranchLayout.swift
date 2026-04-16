import SwiftUI

struct TreeBranchLayout: View {
    let lessons: [Lesson]
    let statusProvider: (Lesson) -> NodeStatus
    let accent: Color
    let onTap: (Lesson) -> Void

    private let verticalSpacing: CGFloat = 130
    private let horizontalOffset: CGFloat = 70
    private let topPadding: CGFloat = 60

    private func xOffset(for index: Int) -> CGFloat {
        let pattern: [CGFloat] = [0, 1, 0, -1]
        return pattern[index % pattern.count] * horizontalOffset
    }

    private func y(forIndex i: Int) -> CGFloat {
        CGFloat(i) * verticalSpacing + topPadding
    }

    private var totalHeight: CGFloat {
        y(forIndex: max(0, lessons.count - 1)) + 100
    }

    var body: some View {
        GeometryReader { geo in
            let centerX = geo.size.width / 2
            ZStack {
                Canvas { ctx, _ in
                    guard lessons.count > 1 else { return }
                    for i in 0..<(lessons.count - 1) {
                        let p1 = CGPoint(x: centerX + xOffset(for: i), y: y(forIndex: i))
                        let p2 = CGPoint(x: centerX + xOffset(for: i + 1), y: y(forIndex: i + 1))
                        var path = Path()
                        path.move(to: p1)
                        path.addQuadCurve(
                            to: p2,
                            control: CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
                        )
                        let color = connectorColor(from: i)
                        ctx.stroke(
                            path,
                            with: .color(color),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [6, 8])
                        )
                    }
                }

                ForEach(Array(lessons.enumerated()), id: \.element.id) { index, lesson in
                    Button {
                        onTap(lesson)
                    } label: {
                        LessonNodeView(
                            lesson: lesson,
                            status: statusProvider(lesson),
                            accent: accent
                        )
                    }
                    .buttonStyle(.plain)
                    .position(x: centerX + xOffset(for: index), y: y(forIndex: index))
                }
            }
            .frame(width: geo.size.width, height: totalHeight)
        }
        .frame(height: totalHeight)
    }

    private func connectorColor(from index: Int) -> Color {
        let from = statusProvider(lessons[index])
        let to = statusProvider(lessons[index + 1])
        if from == .completed && (to == .completed || to == .available || to == .inProgress) {
            return accent.opacity(0.6)
        }
        return Color.secondary.opacity(0.25)
    }
}
