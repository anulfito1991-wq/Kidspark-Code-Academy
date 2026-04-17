# Final Compliance Sweep — 2026-04-17

Pass over the shipped build against the April 2026 App Review rubric.
Green = shipped. Amber = decision needed before submission. Red = blocker.

---

## GREEN — verified shipped

| Area | Check | Evidence |
|---|---|---|
| **Guideline 1.3 (Kids)** | Paywall buttons gated by 3s press-and-hold | `PaywallView.swift` ParentalGate |
| **Guideline 1.3 (Kids)** | Notifications not requested at launch | `RootTabView.swift` — prompt removed from bootstrap |
| **Guideline 1.3 (Kids)** | Parent Dashboard PIN-protected | `ParentPINGate.swift` + hashed PIN in Keychain |
| **Guideline 4.8 (Sign-in)** | No sign-in required | No account system exists |
| **Guideline 5.1.1 (Privacy)** | Privacy Policy hosted + accessible | https://anulfito1991-wq.github.io/Kidspark-Code-Academy/ → 200 |
| **Guideline 5.1.1 (Privacy)** | Terms of Use hosted + accessible | /terms.html → 200 |
| **Guideline 5.1.1 (Privacy)** | No third-party analytics SDKs | Grep returned 0 matches for Firebase/Mixpanel/Amplitude/Segment/FB SDK etc. |
| **Guideline 5.1.1 (Privacy)** | PrivacyInfo.xcprivacy present | `Code app for kids/PrivacyInfo.xcprivacy` (NSPrivacyTracking=false, UserDefaults CA92.1) |
| **Guideline 5.1.4 (Kids)** | COPPA §312.4 notice in privacy policy | `docs/index.html` §4 |
| **Guideline 5.1.4 (Kids)** | COPPA §312.6 review/deletion path | `docs/index.html` §4 — "uninstall clears all local progress" |
| **State privacy laws** | VCDPA, CPA, CTDPA, UCPA covered | `docs/index.html` §12a |
| **GDPR Article 8** | No data collected from children | Privacy policy + Data Not Collected manifest |
| **CCPA / CPRA** | Rights statement in privacy policy | `docs/index.html` §12 |
| **Export Compliance** | `ITSAppUsesNonExemptEncryption = NO` | Verified via `xcodebuild -showBuildSettings` — key is present in Release |
| **Guideline 3.1.2 (Subs)** | Subscription disclosure block visible | `PaywallView.swift` disclosureBlock — renewal terms, cancel path, links |
| **Guideline 3.1.2 (Subs)** | Links to Terms + Privacy from paywall | Shipped |
| **Guideline 2.1 (App completeness)** | No placeholders, no TODO/FIXME | Grep: 0 matches in Swift code |
| **Guideline 2.3.7 (Metadata)** | Support email resolves | Verified — kidspark.academy.learning@gmail.com confirmed by user |
| **Data Not Collected posture** | No PII ever persisted | SwiftData local store only; Keychain holds only PIN hash |
| **App Icon** | All 13 slots populated at exact px | Verified via `sips -g pixelWidth/Height` |
| **Build** | Clean build with Release config | `xcodebuild` succeeds |

## AMBER — decisions the owner must make before submission

### A1. Supported platforms — RESOLVED ✅
Build settings are now scoped to **iPhone + iPad** only:
```
SUPPORTED_PLATFORMS = iphoneos iphonesimulator
TARGETED_DEVICE_FAMILY = "1,2"   # iPhone + iPad
```
Mac Catalyst and visionOS removed. Build verified clean under this scope.

iPad support adds one required screenshot size (13" iPad Pro) — see
`02-screenshots-plan.md`. QA should also include a quick pass on an iPad
simulator to catch any layout issues that wouldn't surface on iPhone.

### A2. Kids Category vs Education category
See `04-category-decision.md`. Recommendation: **Education**. Decide and
I'll update the copy pack if needed.

### A3. Bundle version bump for TestFlight
Currently `MARKETING_VERSION = 1.0, CURRENT_PROJECT_VERSION = 1`. That's fine
for the first TestFlight build. Each subsequent upload must increment
`CURRENT_PROJECT_VERSION` (Build number). Keep `1.0` as Marketing Version
until the real public release.

### A4. First-launch Age Gate copy
Verify the Age Gate text is age-appropriate and asks age ranges, not exact
DOB (per COPPA best practice). Currently implemented — worth a manual read
during your own device test.

## RED — blockers

**None.** Every submission blocker identified in the audit has been resolved.

---

## Residual soft risks (not blockers, worth noting)

- **Marketing icon polish.** The shipped 1024 is the SVG sample from my draft.
  Submission will technically pass App Review but a Figma-polished version
  will improve conversion on the App Store page.
- **Screenshots with bare simulator chrome** can look unpolished vs competitors
  who use device frames + marketing overlays. The screenshots plan covers
  this — optional but high-ROI.
- **No localization.** English-only. Not a blocker; just limits initial
  addressable market. Queue for post-launch.
- **No in-app rating prompt.** Apple allows `SKStoreReviewController` up to
  3x/year; adding one after ~3 successful lessons is an easy v1.1.

---

## What I couldn't verify without your hardware

- App icon renders correctly on a real device home screen (simulator is
  usually faithful but a real-device check is cheap insurance).
- StoreKit sandbox purchases complete end-to-end through a real sandbox
  Apple ID (only possible once ASC products are live).
- Push notification flow on a real device once a parent taps "Enable
  reminders" — simulator doesn't reliably deliver notifications.
