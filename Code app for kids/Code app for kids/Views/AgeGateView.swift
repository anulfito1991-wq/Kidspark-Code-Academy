import SwiftUI

// Neutral-screen age gate shown on first launch.
// - Kid picks Under 13 / 13+ (no birthdate, no PII collected).
// - Under 13 → parent-awareness screen confirming the app collects no personal data.
// - Choice is stored on the Learner so this only appears once.
struct AgeGateView: View {
    @Environment(AppState.self) private var appState

    @State private var selectedUnder13: Bool?
    @State private var consentChecked: Bool = false

    var body: some View {
        ZStack {
            KidSpark.Colors.heroGradient.ignoresSafeArea()

            if let under13 = selectedUnder13, under13 {
                parentScreen
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
            } else {
                agePicker
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: selectedUnder13)
    }

    // MARK: Step 1 — Age selection

    private var agePicker: some View {
        VStack(spacing: 28) {
            Spacer()

            KidSpark.LogoMark(size: 80)
                .shadow(color: .black.opacity(0.2), radius: 16, y: 6)

            VStack(spacing: 8) {
                Text("Welcome!")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Text("How old are you?")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
            }

            VStack(spacing: 14) {
                ageButton(title: "I'm under 13", emoji: "🧒") {
                    selectedUnder13 = true
                }
                .accessibilityLabel("I'm under 13 years old")
                .accessibilityHint("A grown-up will be asked to continue")

                ageButton(title: "I'm 13 or older", emoji: "🧑") {
                    selectedUnder13 = false
                    appState.completeAgeGate(isUnder13: false)
                }
                .accessibilityLabel("I'm 13 or older")
            }
            .padding(.horizontal, 32)

            Text("KidSpark Academy never collects personal data.\nEverything you do stays on this device.")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.75))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
        }
    }

    private func ageButton(title: String, emoji: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Text(emoji).font(.system(size: 28))
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(KidSpark.Colors.spark)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(KidSpark.Colors.spark.opacity(0.6))
            }
            .padding(.horizontal, 20)
            .frame(height: 64)
            .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
        }
        .buttonStyle(.plain)
    }

    // MARK: Step 2 — Parent awareness (only for Under 13)

    private var parentScreen: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(.white.opacity(0.18))
                    .frame(width: 96, height: 96)
                Image(systemName: "person.2.fill")
                    .font(.system(size: 42))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 10) {
                Text("A note for grown-ups")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Text("Please have a parent or guardian tap below.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)

            VStack(alignment: .leading, spacing: 12) {
                infoRow(icon: "lock.shield.fill", text: "No personal data is collected.")
                infoRow(icon: "iphone", text: "All progress stays on this device.")
                infoRow(icon: "nosign", text: "No ads, no tracking, no third parties.")
                infoRow(icon: "person.2.fill", text: "A Parent Dashboard is available, protected by a PIN you set.")
            }
            .padding(18)
            .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .padding(.horizontal, 24)

            Link("Read our privacy policy",
                 destination: URL(string: "https://anulfito1991-wq.github.io/Kidspark-Code-Academy/")!)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white)
                .underline()

            // Required consent checkbox (COPPA §312.4 direct-notice record)
            Button {
                consentChecked.toggle()
            } label: {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: consentChecked ? "checkmark.square.fill" : "square")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("I am the parent or legal guardian, and I have read the privacy policy.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
                .padding(14)
                .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .accessibilityLabel("Parental consent checkbox")
            .accessibilityValue(consentChecked ? "Checked" : "Unchecked")
            .accessibilityHint("Required: confirm you are the parent or guardian and have read the privacy policy")

            VStack(spacing: 10) {
                Button {
                    appState.completeAgeGate(isUnder13: true, parentConsent: true)
                } label: {
                    Text("I'm a parent — let them learn")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(consentChecked ? KidSpark.Colors.spark : .secondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(consentChecked ? AnyShapeStyle(.white) : AnyShapeStyle(Color.white.opacity(0.5)),
                                    in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
                }
                .buttonStyle(.plain)
                .disabled(!consentChecked)

                Button("Back") {
                    selectedUnder13 = nil
                    consentChecked = false
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white.opacity(0.85))
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }

    private func infoRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 24)
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
