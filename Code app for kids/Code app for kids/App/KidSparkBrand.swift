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

        /// Soft lavender page background (adaptive for light/dark mode).
        /// Light: warm lavender that still pairs with our brand purple.
        /// Dark: deep near-black with a hint of indigo so gradients and
        /// colored accents still pop without washing out body text.
        static let pageBackground = Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.07, green: 0.06, blue: 0.11, alpha: 1.0)  // #12101C
                : UIColor(red: 0.96, green: 0.94, blue: 1.00, alpha: 1.0)  // #F5F0FF
        })
        /// Card surface (adaptive). Pure white in light; elevated gray in dark.
        static let cardSurface = Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.13, green: 0.12, blue: 0.17, alpha: 1.0)  // #21202B
                : UIColor.white
        })

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
                        .foregroundStyle(textColor.opacity(0.85))
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
    /// Default card uses the adaptive `cardSurface` so it reads correctly in
    /// both light and dark mode. Callers can still override `tint` for accent
    /// surfaces (e.g. colored callouts), but pure white has been removed as a
    /// default because it blasted out in dark mode.
    func kidSparkCard(tint: Color = KidSpark.Colors.cardSurface, shadow: Bool = true) -> some View {
        self
            .padding(AppTheme.cardPadding)
            .background(tint, in: RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous))
            .shadow(color: AppTheme.softShadow, radius: shadow ? 8 : 0, y: shadow ? 3 : 0)
    }

    func cardStyle(tint: Color = KidSpark.Colors.cardSurface) -> some View {
        kidSparkCard(tint: tint)
    }
}
