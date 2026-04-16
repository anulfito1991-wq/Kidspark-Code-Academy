import SwiftUI

struct RewardStepView: View {
    let xp: Int
    let accent: Color
    let earnedBadges: [Badge]
    let milestone: XPMilestone?
    let onContinue: () -> Void

    @State private var animate: Bool = false
    @State private var xpScale: Double = 0.5

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [accent.opacity(0.12), KidSpark.Colors.pageBackground],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            ConfettiView(isActive: animate)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    Spacer(minLength: 24)

                    // Star burst
                    ZStack {
                        ForEach(0..<8) { i in
                            Image(systemName: "star.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(accent.opacity(0.3))
                                .offset(
                                    x: cos(Double(i) * .pi / 4) * 60,
                                    y: sin(Double(i) * .pi / 4) * 60
                                )
                                .scaleEffect(animate ? 1 : 0)
                                .animation(
                                    .spring(response: 0.5, dampingFraction: 0.6).delay(Double(i) * 0.05),
                                    value: animate
                                )
                        }
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 104))
                            .foregroundStyle(LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .scaleEffect(animate ? 1.0 : 0.4)
                            .animation(.spring(response: 0.5, dampingFraction: 0.5), value: animate)
                    }

                    // Completion headline
                    VStack(spacing: 6) {
                        Text("Lesson complete! 🎉")
                            .font(KidSpark.Fonts.title)
                        Text("You're getting smarter every day.")
                            .font(KidSpark.Fonts.callout)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    // XP pill
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.fill")
                            .foregroundStyle(KidSpark.Colors.glow)
                        Text("+\(xp) XP")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .monospacedDigit()
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [KidSpark.Colors.glow.opacity(0.15), KidSpark.Colors.tangerine.opacity(0.15)],
                            startPoint: .leading, endPoint: .trailing
                        ),
                        in: Capsule()
                    )
                    .scaleEffect(xpScale)
                    .animation(.spring(response: 0.4, dampingFraction: 0.55).delay(0.2), value: xpScale)

                    // Badges earned
                    if !earnedBadges.isEmpty {
                        VStack(spacing: 14) {
                            Label("New badge\(earnedBadges.count > 1 ? "s" : "") unlocked!", systemImage: "rosette")
                                .font(KidSpark.Fonts.headline)
                                .foregroundStyle(KidSpark.Colors.coral)
                            HStack(spacing: 18) {
                                ForEach(earnedBadges) { badge in
                                    VStack(spacing: 8) {
                                        Text(badge.emoji)
                                            .font(.system(size: 40))
                                            .frame(width: 68, height: 68)
                                            .background(badge.accent.opacity(0.15), in: Circle())
                                            .overlay(Circle().stroke(badge.accent.opacity(0.3), lineWidth: 2))
                                        Text(badge.title)
                                            .font(KidSpark.Fonts.caption2)
                                            .multilineTextAlignment(.center)
                                            .frame(width: 90)
                                    }
                                }
                            }
                        }
                        .kidSparkCard()
                    }

                    // XP Milestone coach message
                    if let milestone {
                        CoachCard(milestone: milestone)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    Spacer(minLength: 8)

                    Button(action: onContinue) {
                        HStack(spacing: 8) {
                            Text("Keep going")
                                .font(KidSpark.Fonts.headline)
                            Image(systemName: "arrow.right")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(colors: [accent, accent.opacity(0.8)],
                                           startPoint: .leading, endPoint: .trailing),
                            in: Capsule()
                        )
                        .foregroundStyle(.white)
                        .shadow(color: accent.opacity(0.35), radius: 10, y: 4)
                    }
                    .padding(.bottom, 12)
                }
                .padding(.horizontal, KidSpark.Layout.pagePadding)
            }
        }
        .onAppear {
            withAnimation { animate = true }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.55).delay(0.2)) {
                xpScale = 1.0
            }
        }
    }
}
