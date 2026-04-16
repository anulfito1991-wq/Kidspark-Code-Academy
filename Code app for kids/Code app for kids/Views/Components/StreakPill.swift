import SwiftUI

struct StreakPill: View {
    let days: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: days > 0 ? "flame.fill" : "flame")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(days > 0 ? KidSpark.Colors.tangerine : Color.secondary)
                .symbolEffect(.bounce, value: days)
            Text("\(days)")
                .font(.system(size: 17, weight: .black, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(days > 0 ? KidSpark.Colors.tangerine : .secondary)
            Text(days == 1 ? "day streak" : "day streak")
                .font(KidSpark.Fonts.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            (days > 0 ? KidSpark.Colors.tangerine : Color.secondary).opacity(0.1),
            in: Capsule()
        )
    }
}
