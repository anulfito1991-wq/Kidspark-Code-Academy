import SwiftUI

// Wraps any view behind a 4-digit PIN.
// - First entry sets the PIN; subsequent entries verify it.
// - SHA-256 hash is stored in the Keychain via ParentPINStore.
// - Re-locks when the app backgrounds or after 5 min of inactivity.
// - After 5 wrong attempts the pad is locked for an escalating cooldown.
// - "Forgot PIN?" clears the hash (via a typed phrase) without wiping progress.
struct ParentPINGate<Content: View>: View {
    @ViewBuilder let content: Content

    @Environment(\.scenePhase) private var scenePhase

    @State private var enteredPIN: String = ""
    @State private var isUnlocked: Bool = false
    @State private var isSettingPIN: Bool = false
    @State private var confirmPIN: String = ""
    @State private var shakeTrigger: Bool = false
    @State private var errorMessage: String = ""
    @State private var unlockedAt: Date = .distantPast
    @State private var showResetSheet: Bool = false
    // Tick bumped once per second ONLY while a lockout is active. Used as the
    // body-invalidation trigger so the countdown visibly decreases. When not
    // locked out no timer runs at all.
    @State private var lockoutTick: Int = 0

    // Computed — reads the lockout state on demand. The `_ = lockoutTick` line
    // registers a body-dependency so SwiftUI re-renders each tick without us
    // having to mirror the value into another @State.
    private var lockoutRemaining: TimeInterval {
        _ = lockoutTick
        return ParentPINStore.lockoutRemaining()
    }

    var body: some View {
        Group {
            if isUnlocked {
                content
                    .onAppear { unlockedAt = .now }
                    .simultaneousGesture(TapGesture().onEnded { unlockedAt = .now })
                    // Auto-lock after idle. `.task(id:)` restarts whenever unlockedAt
                    // changes (on tap), so the sleep is cancelled + rescheduled.
                    .task(id: unlockedAt) {
                        try? await Task.sleep(nanoseconds: UInt64(ParentPINStore.idleTimeout * 1_000_000_000))
                        if !Task.isCancelled { lock() }
                    }
            } else {
                pinScreen
                    // Drive a 1Hz tick ONLY while a lockout countdown is running.
                    // Off-screen / unlocked → no timer work.
                    .task(id: lockoutRemaining > 0) {
                        while !Task.isCancelled, ParentPINStore.lockoutRemaining() > 0 {
                            try? await Task.sleep(nanoseconds: 1_000_000_000)
                            lockoutTick &+= 1
                        }
                    }
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase != .active { lock() }
        }
        .onAppear {
            isSettingPIN = !ParentPINStore.hasPIN
        }
        .sheet(isPresented: $showResetSheet) {
            PINResetSheet {
                ParentPINStore.reset()
                enteredPIN = ""
                confirmPIN = ""
                errorMessage = ""
                isSettingPIN = true
                showResetSheet = false
            }
        }
    }

    private var pinScreen: some View {
        ZStack {
            KidSpark.Colors.pageBackground.ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                VStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(KidSpark.Colors.spark.opacity(0.12))
                            .frame(width: 80, height: 80)
                        Image(systemName: lockoutRemaining > 0 ? "lock.fill" : "person.2.fill")
                            .font(.system(size: 34))
                            .foregroundStyle(KidSpark.Colors.spark)
                    }
                    Text("Parent Dashboard")
                        .font(.system(size: 26, weight: .black))
                    Text(headerText)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

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
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                PINPad(disabled: lockoutRemaining > 0) { digit in
                    handleInput(digit)
                } onDelete: {
                    guard lockoutRemaining == 0 else { return }
                    if !currentEntry.isEmpty {
                        if isSettingPIN && !confirmPIN.isEmpty {
                            confirmPIN.removeLast()
                        } else {
                            enteredPIN.removeLast()
                        }
                        errorMessage = ""
                    }
                }

                if !isSettingPIN && ParentPINStore.hasPIN {
                    Button("Forgot PIN?") { showResetSheet = true }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(KidSpark.Colors.spark)
                }

                Spacer()
            }
        }
    }

    private var headerText: String {
        if lockoutRemaining > 0 {
            let secs = Int(lockoutRemaining.rounded(.up))
            return "Too many wrong attempts. Try again in \(secs)s."
        }
        if isSettingPIN {
            return confirmPIN.isEmpty
                ? "Create a 4-digit PIN to protect this area."
                : "Re-enter your PIN to confirm."
        }
        return "Enter your 4-digit PIN."
    }

    private var currentEntry: String {
        isSettingPIN && !confirmPIN.isEmpty ? confirmPIN : enteredPIN
    }

    private func handleInput(_ digit: String) {
        guard lockoutRemaining == 0 else { return }
        errorMessage = ""
        if isSettingPIN {
            if confirmPIN.isEmpty {
                if enteredPIN.count < 4 {
                    enteredPIN.append(digit)
                    if enteredPIN.count == 4 { confirmPIN = "" }
                }
            } else {
                if confirmPIN.count < 4 {
                    confirmPIN.append(digit)
                    if confirmPIN.count == 4 {
                        if confirmPIN == enteredPIN {
                            ParentPINStore.setPIN(enteredPIN)
                            isUnlocked = true
                            unlockedAt = .now
                            isSettingPIN = false
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
                    if ParentPINStore.verify(enteredPIN) {
                        isUnlocked = true
                        unlockedAt = .now
                    } else {
                        // Bump the tick so the computed `lockoutRemaining` refreshes.
                        lockoutTick &+= 1
                        errorMessage = ParentPINStore.lockoutRemaining() > 0
                            ? "Locked. Try again shortly."
                            : "Wrong PIN. Try again."
                        withAnimation(.default) { shakeTrigger.toggle() }
                        enteredPIN = ""
                    }
                }
            }
        }
    }

    private func lock() {
        if isUnlocked { isUnlocked = false }
        enteredPIN = ""
        confirmPIN = ""
        errorMessage = ""
        lockoutTick &+= 1
        isSettingPIN = !ParentPINStore.hasPIN
    }
}

// MARK: - Reset confirmation sheet

private struct PINResetSheet: View {
    let onConfirm: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var typed: String = ""

    private let phrase = "RESET PIN"

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(KidSpark.Colors.coral)
                    .padding(.top, 24)

                Text("Reset Parent PIN")
                    .font(.system(size: 22, weight: .black))

                Text("This will clear the current PIN so you can set a new one. Learning progress and badges are not affected.")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Text("Type **\(phrase)** to confirm:")
                    .font(.system(size: 13, weight: .medium))

                TextField(phrase, text: $typed)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .padding(12)
                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal, 32)

                Button(action: onConfirm) {
                    Text("Reset PIN")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(typed == phrase ? KidSpark.Colors.coral : Color(.systemGray3),
                                    in: RoundedRectangle(cornerRadius: 14))
                }
                .disabled(typed != phrase)
                .padding(.horizontal, 24)

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Pad

private struct PINPad: View {
    let disabled: Bool
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
                            .accessibilityLabel("Delete last digit")
                        } else {
                            Button { onDigit(key) } label: {
                                Text(key)
                                    .font(.system(size: 22, weight: .semibold))
                                    .frame(width: 72, height: 56)
                                    .background(.white, in: RoundedRectangle(cornerRadius: 12))
                                    .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("\(key)")
                            .accessibilityHint("PIN digit")
                        }
                    }
                }
            }
        }
        .opacity(disabled ? 0.4 : 1)
        .allowsHitTesting(!disabled)
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
