import SwiftUI

struct LessonNodeView: View {
    let lesson: Lesson
    let status: NodeStatus
    let accent: Color

    @State private var pulse: Bool = false

    private var bg: Color {
        switch status {
        case .completed: return accent
        case .inProgress: return accent
        case .available: return .white
        case .locked: return Color(.systemGray5)
        case .proLocked: return Color(.systemGray5)
        }
    }

    private var iconColor: Color {
        switch status {
        case .completed, .inProgress: return .white
        case .available: return accent
        case .locked: return Color(.systemGray3)
        case .proLocked: return KidSpark.Colors.spark.opacity(0.6)
        }
    }

    private var icon: String {
        switch status {
        case .completed: return "checkmark"
        case .inProgress: return "play.fill"
        case .available: return lesson.tier.badgeIcon
        case .locked: return "lock.fill"
        case .proLocked: return "crown.fill"
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Glow ring for current/available
                if status == .inProgress || status == .available {
                    Circle()
                        .stroke(accent.opacity(pulse ? 0.35 : 0.15), lineWidth: pulse ? 10 : 6)
                        .frame(width: AppTheme.nodeSize + 16, height: AppTheme.nodeSize + 16)
                        .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: pulse)
                }

                Circle()
                    .fill(bg)
                    .frame(width: AppTheme.nodeSize, height: AppTheme.nodeSize)
                    .shadow(
                        color: (status == .completed || status == .inProgress) ? accent.opacity(0.4) : Color.black.opacity(0.08),
                        radius: 8, y: 4
                    )

                Image(systemName: icon)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(iconColor)
            }
            .overlay(alignment: .topTrailing) {
                if status == .proLocked {
                    ProChip().offset(x: 6, y: -6)
                }
            }

            Text(lesson.title)
                .font(KidSpark.Fonts.caption)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(maxWidth: 110)
                .foregroundStyle(status == .locked || status == .proLocked ? Color.secondary : .primary)
        }
        .onAppear { pulse = true }
    }
}
