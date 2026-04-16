import SwiftUI

private let pinKey = "kidspark_parent_pin"

// Wraps any view behind a 4-digit PIN. First entry sets the PIN; subsequent entries verify it.
struct ParentPINGate<Content: View>: View {
    @ViewBuilder let content: Content

    @State private var enteredPIN: String = ""
    @State private var isUnlocked: Bool = false
    @State private var isSettingPIN: Bool = false
    @State private var confirmPIN: String = ""
    @State private var shakeTrigger: Bool = false
    @State private var errorMessage: String = ""

    private var storedPIN: String? { UserDefaults.standard.string(forKey: pinKey) }

    var body: some View {
        if isUnlocked {
            content
        } else {
            pinScreen
        }
    }

    private var pinScreen: some View {
        ZStack {
            KidSpark.Colors.pageBackground.ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                // Icon + header
                VStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(KidSpark.Colors.spark.opacity(0.12))
                            .frame(width: 80, height: 80)
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 34))
                            .foregroundStyle(KidSpark.Colors.spark)
                    }
                    Text("Parent Dashboard")
                        .font(.system(size: 26, weight: .black))
                    Text(isSettingPIN
                         ? (confirmPIN.isEmpty ? "Create a 4-digit PIN to protect this area." : "Re-enter your PIN to confirm.")
                         : "Enter your 4-digit PIN.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                // Dots
                HStack(spacing: 16) {
                    ForEach(0..<4, id: \.self) { i in
                        Circle()
                            .fill(currentEntry.count > i ? KidSpark.Colors.spark : Color(.systemGray4))
                            .frame(width: 16, height: 16)
                    }
                }
                .modifier(ShakeEffect(trigger: shakeTrigger))

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(KidSpark.Colors.coral)
                }

                // Number pad
                PINPad { digit in
                    handleInput(digit)
                } onDelete: {
                    if !currentEntry.isEmpty {
                        if isSettingPIN && !confirmPIN.isEmpty {
                            confirmPIN.removeLast()
                        } else {
                            enteredPIN.removeLast()
                        }
                        errorMessage = ""
                    }
                }

                Spacer()
            }
        }
        .onAppear {
            isSettingPIN = storedPIN == nil
        }
    }

    private var currentEntry: String {
        isSettingPIN && !confirmPIN.isEmpty ? confirmPIN : enteredPIN
    }

    private func handleInput(_ digit: String) {
        errorMessage = ""
        if isSettingPIN {
            if confirmPIN.isEmpty {
                if enteredPIN.count < 4 {
                    enteredPIN.append(digit)
                    if enteredPIN.count == 4 {
                        // Move to confirm step
                        confirmPIN = ""
                    }
                }
            } else {
                if confirmPIN.count < 4 {
                    confirmPIN.append(digit)
                    if confirmPIN.count == 4 {
                        if confirmPIN == enteredPIN {
                            UserDefaults.standard.set(enteredPIN, forKey: pinKey)
                            isUnlocked = true
                        } else {
                            errorMessage = "PINs don't match. Try again."
                            withAnimation(.default) { shakeTrigger.toggle() }
                            enteredPIN = ""
                            confirmPIN = ""
                        }
                    }
                }
            }
        } else {
            if enteredPIN.count < 4 {
                enteredPIN.append(digit)
                if enteredPIN.count == 4 {
                    if enteredPIN == storedPIN {
                        isUnlocked = true
                    } else {
                        errorMessage = "Wrong PIN. Try again."
                        withAnimation(.default) { shakeTrigger.toggle() }
                        enteredPIN = ""
                    }
                }
            }
        }
    }
}

private struct PINPad: View {
    let onDigit: (String) -> Void
    let onDelete: () -> Void

    private let layout = [
        ["1","2","3"],
        ["4","5","6"],
        ["7","8","9"],
        ["","0","⌫"]
    ]

    var body: some View {
        VStack(spacing: 12) {
            ForEach(layout, id: \.self) { row in
                HStack(spacing: 20) {
                    ForEach(row, id: \.self) { key in
                        if key.isEmpty {
                            Color.clear.frame(width: 72, height: 56)
                        } else if key == "⌫" {
                            Button(action: onDelete) {
                                Image(systemName: "delete.left")
                                    .font(.system(size: 20, weight: .semibold))
                                    .frame(width: 72, height: 56)
                                    .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                        } else {
                            Button { onDigit(key) } label: {
                                Text(key)
                                    .font(.system(size: 22, weight: .semibold))
                                    .frame(width: 72, height: 56)
                                    .background(.white, in: RoundedRectangle(cornerRadius: 12))
                                    .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }
}

private struct ShakeEffect: ViewModifier {
    var trigger: Bool

    func body(content: Content) -> some View {
        content
            .offset(x: trigger ? -8 : 0)
            .animation(
                .interpolatingSpring(stiffness: 600, damping: 8)
                    .repeatCount(3, autoreverses: true),
                value: trigger
            )
    }
}
