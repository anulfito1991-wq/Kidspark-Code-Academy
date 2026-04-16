import SwiftUI

struct ChallengeCard: View {
    let entry: ChallengeEntry
    let isCompleted: Bool
    let onTap: () -> Void

    @State private var timeRemaining: String = ""
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isCompleted ? KidSpark.Colors.leaf : KidSpark.Colors.spark)
                        .frame(width: 52, height: 52)
                    Image(systemName: isCompleted ? "checkmark.seal.fill" : "bolt.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text("WEEKLY CHALLENGE")
                            .font(.system(size: 10, weight: .black))
                            .foregroundStyle(isCompleted ? KidSpark.Colors.leaf : KidSpark.Colors.spark)
                            .tracking(1)
                        Spacer()
                        Text(isCompleted ? "Done ✓" : timeRemaining)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(isCompleted ? KidSpark.Colors.leaf : .secondary)
                    }
                    Text(entry.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.primary)
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(KidSpark.Colors.glow)
                        Text("+\(entry.xpReward) XP")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(languageLabel)
                            .font(.system(size: 11, weight: .medium))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(KidSpark.Colors.sky.opacity(0.15), in: Capsule())
                            .foregroundStyle(KidSpark.Colors.sky)
                    }
                }
            }
            .padding(14)
            .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            .opacity(isCompleted ? 0.75 : 1)
        }
        .buttonStyle(.plain)
        .onAppear { updateCountdown() }
        .onReceive(timer) { _ in updateCountdown() }
    }

    private var languageLabel: String {
        switch entry.languageID {
        case "swift": return "Swift"
        case "python": return "Python"
        case "javascript": return "JS"
        case "scratch": return "Scratch"
        default: return entry.languageID.capitalized
        }
    }

    private func updateCountdown() {
        let secs = ChallengeService.secondsUntilNextWeek()
        let days = Int(secs) / 86400
        let hours = (Int(secs) % 86400) / 3600
        if days > 0 {
            timeRemaining = "\(days)d \(hours)h left"
        } else if hours > 0 {
            timeRemaining = "\(hours)h left"
        } else {
            let mins = (Int(secs) % 3600) / 60
            timeRemaining = "\(mins)m left"
        }
    }
}
