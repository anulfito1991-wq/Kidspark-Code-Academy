import SwiftUI

struct ExplainerStepView: View {
    let step: ExplainerStep
    let accent: Color
    let onContinue: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(step.title)
                .font(KidSpark.Fonts.title)
            Text(step.body)
                .font(KidSpark.Fonts.body)
                .foregroundStyle(.primary)
                .lineSpacing(4)

            if let code = step.codeSample {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Circle().fill(Color(hex: "#F43F5E")!).frame(width: 10, height: 10)
                        Circle().fill(Color(hex: "#F59E0B")!).frame(width: 10, height: 10)
                        Circle().fill(Color(hex: "#10B981")!).frame(width: 10, height: 10)
                        Spacer()
                        Text("Code")
                            .font(KidSpark.Fonts.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 10)

                    ScrollView(.horizontal, showsIndicators: false) {
                        Text(code)
                            .font(.system(.body, design: .monospaced))
                            .padding(.horizontal, 12)
                            .padding(.bottom, 12)
                    }
                }
                .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }

            Spacer()

            Button(action: onContinue) {
                HStack(spacing: 8) {
                    Text("Got it!")
                        .font(KidSpark.Fonts.headline)
                    Image(systemName: "arrow.right")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(colors: [accent, accent.opacity(0.8)], startPoint: .leading, endPoint: .trailing),
                    in: Capsule()
                )
                .foregroundStyle(.white)
                .shadow(color: accent.opacity(0.35), radius: 8, y: 4)
            }
        }
        .padding()
    }
}
