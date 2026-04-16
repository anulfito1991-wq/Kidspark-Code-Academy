import SwiftUI

struct XPBar: View {
    let xp: Int

    private var level: Int { XPService.level(for: xp) }
    private var intoLevel: Int { XPService.xpIntoLevel(xp) }
    private var fraction: Double { XPService.xpProgressFraction(xp) }
    private var toNext: Int { XPService.xpToNextLevel(xp) }

    var body: some View {
        HStack(spacing: 14) {
            // Level badge circle
            ZStack {
                Circle()
                    .fill(KidSpark.Colors.heroGradient)
                    .frame(width: 52, height: 52)
                VStack(spacing: 0) {
                    Text("\(level)")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text("LVL")
                        .font(.system(size: 8, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("XP")
                        .font(KidSpark.Fonts.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(toNext) to next level")
                        .font(KidSpark.Fonts.caption)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.12))
                            .frame(height: 14)
                        Capsule()
                            .fill(KidSpark.Colors.xpGradient)
                            .frame(width: max(14, geo.size.width * fraction), height: 14)
                            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: fraction)
                        // XP sparkle dots at edges
                        if fraction > 0.05 {
                            Image(systemName: "sparkle")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(.white.opacity(0.9))
                                .offset(x: max(4, geo.size.width * fraction - 14))
                        }
                    }
                }
                .frame(height: 14)
            }
        }
    }
}
