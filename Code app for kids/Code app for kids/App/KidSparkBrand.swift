import SwiftUI

// MARK: - KidSpark Academy Brand System

enum KidSpark {

    // MARK: Colors
    enum Colors {
        /// Primary brand purple — energy, creativity, curiosity
        static let spark = Color(hex: "#7C3AED")!
        /// Sunshine yellow — XP, achievement, delight
        static let glow = Color(hex: "#F59E0B")!
        /// Coral pink — excitement, badges, rewards
        static let coral = Color(hex: "#F43F5E")!
        /// Leaf green — correct, success, growth
        static let leaf = Color(hex: "#10B981")!
        /// Sky blue — calm learning, information
        static let sky = Color(hex: "#0EA5E9")!
        /// Tangerine — streak fire, energy
        static let tangerine = Color(hex: "#F97316")!
        /// Mint — secondary success tone
        static let mint = Color(hex: "#14B8A6")!

        /// Soft lavender page background
        static let pageBackground = Color(hex: "#F5F0FF")!
        /// Card surface
        static let cardSurface = Color(hex: "#FFFFFF")!

        /// Gradient for hero areas
        static let heroGradient = LinearGradient(
            colors: [spark, Color(hex: "#A855F7")!],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        /// Gradient for XP bar
        static let xpGradient = LinearGradient(
            colors: [glow, tangerine],
            startPoint: .leading,
            endPoint: .trailing
        )

        /// Gradient for streak bar
        static let streakGradient = LinearGradient(
            colors: [tangerine, coral],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    // MARK: Typography
    enum Fonts {
        static let display = Font.system(.largeTitle, design: .rounded, weight: .black)
        static let title = Font.system(.title, design: .rounded, weight: .bold)
        static let title2 = Font.system(.title2, design: .rounded, weight: .bold)
        static let headline = Font.system(.headline, design: .rounded, weight: .semibold)
        static let body = Font.system(.body, design: .rounded)
        static let callout = Font.system(.callout, design: .rounded)
        static let caption = Font.system(.caption, design: .rounded, weight: .medium)
        static let caption2 = Font.system(.caption2, design: .rounded, weight: .bold)
    }

    // MARK: Layout
    enum Layout {
        static let cornerRadius: CGFloat = 24
        static let cardCornerRadius: CGFloat = 20
        static let nodeSize: CGFloat = 76
        static let cardPadding: CGFloat = 18
        static let pagePadding: CGFloat = 20
    }

    // MARK: Logo mark (pure SwiftUI)
    struct LogoMark: View {
        var size: CGFloat = 44

        var body: some View {
            ZStack {
                Circle()
                    .fill(Colors.heroGradient)
                    .frame(width: size, height: size)
                Image(systemName: "bolt.fill")
                    .font(.system(size: size * 0.44, weight: .black))
                    .foregroundStyle(.white)
            }
        }
    }

    // MARK: Brand word-mark
    struct WordMark: View {
        var textColor: Color = .primary

        var body: some View {
            HStack(spacing: 6) {
                LogoMark(size: 32)
                VStack(alignment: .leading, spacing: -2) {
                    Text("KidSpark")
                        .font(Font.system(.headline, design: .rounded, weight: .black))
                        .foregroundStyle(Colors.spark)
                    Text("Academy")
                        .font(Font.system(.caption, design: .rounded, weight: .semibold))
                        .foregroundStyle(textColor.opacity(0.6))
                }
            }
        }
    }
}

// MARK: - Updated AppTheme using brand
enum AppTheme {
    static let cornerRadius: CGFloat = KidSpark.Layout.cornerRadius
    static let cardCornerRadius: CGFloat = KidSpark.Layout.cardCornerRadius
    static let cardPadding: CGFloat = KidSpark.Layout.cardPadding
    static let nodeSize: CGFloat = KidSpark.Layout.nodeSize
    static let softShadow: Color = Color.black.opacity(0.07)
}

extension View {
    func kidSparkCard(tint: Color = .white, shadow: Bool = true) -> some View {
        self
            .padding(AppTheme.cardPadding)
            .background(tint, in: RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous))
            .shadow(color: AppTheme.softShadow, radius: shadow ? 8 : 0, y: shadow ? 3 : 0)
    }

    func cardStyle(tint: Color = .white) -> some View {
        kidSparkCard(tint: tint)
    }
}
