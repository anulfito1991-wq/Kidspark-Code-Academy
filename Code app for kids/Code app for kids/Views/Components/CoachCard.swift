import SwiftUI

/// A friendly coach-tip card shown inline (e.g. in RewardStepView).
struct CoachCard: View {
    let milestone: XPMilestone

    private var accentColor: Color {
        switch milestone.accentKey {
        case "glow": return KidSpark.Colors.glow
        case "coral": return KidSpark.Colors.coral
        case "leaf": return KidSpark.Colors.leaf
        case "sky": return KidSpark.Colors.sky
        case "tangerine": return KidSpark.Colors.tangerine
        default: return KidSpark.Colors.spark
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Text(milestone.emoji)
                    .font(.system(size: 32))
                VStack(alignment: .leading, spacing: 2) {
                    Text(milestone.headline)
                        .font(KidSpark.Fonts.headline)
                        .foregroundStyle(accentColor)
                    Text(milestone.message)
                        .font(KidSpark.Fonts.caption)
                        .foregroundStyle(.primary.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.caption)
                    .foregroundStyle(KidSpark.Colors.glow)
                Text(milestone.coachTip)
                    .font(KidSpark.Fonts.caption)
                    .italic()
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(KidSpark.Colors.glow.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(16)
        .background(accentColor.opacity(0.08), in: RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous)
                .stroke(accentColor.opacity(0.25), lineWidth: 1.5)
        )
    }
}

/// Full-screen overlay shown when a major XP milestone is hit.
struct MilestoneOverlay: View {
    let milestone: XPMilestone
    let onDismiss: () -> Void

    @State private var appear: Bool = false

    private var accentColor: Color {
        switch milestone.accentKey {
        case "glow": return KidSpark.Colors.glow
        case "coral": return KidSpark.Colors.coral
        case "leaf": return KidSpark.Colors.leaf
        case "sky": return KidSpark.Colors.sky
        case "tangerine": return KidSpark.Colors.tangerine
        default: return KidSpark.Colors.spark
        }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.55).ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 24) {
                Text(milestone.emoji)
                    .font(.system(size: 80))
                    .scaleEffect(appear ? 1.0 : 0.4)
                    .animation(.spring(response: 0.5, dampingFraction: 0.5), value: appear)

                VStack(spacing: 8) {
                    Text(milestone.headline)
                        .font(KidSpark.Fonts.display)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(accentColor)
                    Text(milestone.message)
                        .font(KidSpark.Fonts.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 8)
                }

                VStack(spacing: 6) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(KidSpark.Colors.glow)
                    Text(milestone.coachTip)
                        .font(KidSpark.Fonts.callout)
                        .italic()
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(16)
                .background(KidSpark.Colors.glow.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))

                Button(action: onDismiss) {
                    Text("Let's keep going! 🚀")
                        .font(KidSpark.Fonts.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(accentColor, in: Capsule())
                        .foregroundStyle(.white)
                }
            }
            .padding(28)
            .background(
                Color(.systemBackground),
                in: RoundedRectangle(cornerRadius: 32, style: .continuous)
            )
            .shadow(color: accentColor.opacity(0.3), radius: 30, y: 10)
            .padding(.horizontal, 20)
            .scaleEffect(appear ? 1.0 : 0.8)
            .opacity(appear ? 1 : 0)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: appear)
        }
        .onAppear { withAnimation { appear = true } }
    }
}
