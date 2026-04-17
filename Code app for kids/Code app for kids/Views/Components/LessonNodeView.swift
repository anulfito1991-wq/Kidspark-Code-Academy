import SwiftUI

struct LessonNodeView: View {
    let lesson: Lesson
    let status: NodeStatus
    let isHighlighted: Bool
    let accent: Color

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
                // Static highlight for the next actionable lesson. Avoid repeat-forever
                // animations here because the path screen can keep many nodes alive.
                if status == .inProgress || status == .available {
                    Circle()
                        .stroke(
                            accent.opacity(isHighlighted ? 0.28 : 0.14),
                            lineWidth: isHighlighted ? 9 : 5
                        )
                        .frame(width: AppTheme.nodeSize + 16, height: AppTheme.nodeSize + 16)
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel(lesson.title)
        .accessibilityValue(statusLabel)
        .accessibilityHint(status == .available || status == .inProgress ? "Double tap to start the lesson" : "")
    }

    private var statusLabel: String {
        switch status {
        case .completed: return "Completed"
        case .inProgress: return "In progress"
        case .available: return "Ready to start"
        case .locked: return "Locked. Finish the previous lesson to unlock"
        case .proLocked: return "Pro lesson, locked. Upgrade to Pro to unlock"
        }
    }
}
