import Foundation
import CryptoKit
import Security

// Stores a SHA-256 hash of the parent PIN in the Keychain.
// The PIN itself is never persisted. Adds brute-force rate limiting and a
// non-destructive reset path so a forgotten PIN doesn't require wiping progress.
enum ParentPINStore {
    private static let service = "com.kidspark.academy.parentpin"
    private static let account = "parent-pin-hash"

    // Rate-limit state lives in UserDefaults — it's tamper-tolerance, not a secret.
    private static let failCountKey = "kidspark_pin_fail_count"
    private static let lockUntilKey = "kidspark_pin_lock_until"

    // Unlock the PIN after this many seconds of inactivity. Re-check in the view.
    static let idleTimeout: TimeInterval = 5 * 60

    // MARK: PIN lifecycle

    static var hasPIN: Bool { readHash() != nil }

    static func setPIN(_ pin: String) {
        writeHash(hash(pin))
        clearFailState()
    }

    /// Returns true on success. On failure, increments the attempt counter and
    /// may start a lockout. Callers should check `lockoutRemaining()` first.
    static func verify(_ pin: String) -> Bool {
        guard let stored = readHash() else { return false }
        let candidate = hash(pin)
        if constantTimeEquals(stored, candidate) {
            clearFailState()
            return true
        }
        recordFailure()
        return false
    }

    /// Wipes the stored PIN so a new one can be set. Does NOT touch learner progress.
    static func reset() {
        clear()
        clearFailState()
    }

    static func clear() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }

    // MARK: Rate limiting

    /// Seconds remaining in the current lockout, or 0 if unlocked.
    static func lockoutRemaining() -> TimeInterval {
        let until = UserDefaults.standard.double(forKey: lockUntilKey)
        guard until > 0 else { return 0 }
        let remaining = until - Date.now.timeIntervalSince1970
        if remaining <= 0 {
            UserDefaults.standard.removeObject(forKey: lockUntilKey)
            return 0
        }
        return remaining
    }

    private static func recordFailure() {
        let defaults = UserDefaults.standard
        let newCount = defaults.integer(forKey: failCountKey) + 1
        defaults.set(newCount, forKey: failCountKey)

        // Escalating lockouts: 5th fail → 60s, 10th → 5 min, 15th → 15 min, cap there.
        let lockSeconds: TimeInterval? = {
            switch newCount {
            case 5: return 60
            case 10: return 5 * 60
            case let n where n >= 15 && n % 5 == 0: return 15 * 60
            default: return nil
            }
        }()
        if let seconds = lockSeconds {
            defaults.set(Date.now.timeIntervalSince1970 + seconds, forKey: lockUntilKey)
        }
    }

    private static func clearFailState() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: failCountKey)
        defaults.removeObject(forKey: lockUntilKey)
    }

    // MARK: Crypto helpers

    private static func hash(_ pin: String) -> Data {
        Data(SHA256.hash(data: Data(pin.utf8)))
    }

    private static func constantTimeEquals(_ a: Data, _ b: Data) -> Bool {
        guard a.count == b.count else { return false }
        var diff: UInt8 = 0
        for i in 0..<a.count { diff |= a[i] ^ b[i] }
        return diff == 0
    }

    // MARK: Keychain I/O

    private static func readHash() -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else { return nil }
        return data
    }

    private static func writeHash(_ data: Data) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            var add = query
            add.merge(attributes) { _, new in new }
            SecItemAdd(add as CFDictionary, nil)
        }
    }
}
