# KidSpark Academy — Screenshots Plan

Apple requires screenshots for every device size you support. For iPhone + iPad
apps in 2026 you must supply **at least one** of the two required sizes; the
6.9" set cascades down to smaller devices automatically.

## Required sizes (iOS + iPadOS)

| Size label | Device (Simulator) | Resolution (px) | Count |
|---|---|---|---|
| **6.9" iPhone (required)** | iPhone 17 Pro Max | 1320 × 2868 | 3–10 |
| **6.5" iPhone (required)** | iPhone 11 Pro Max | 1242 × 2688 | 3–10 |
| **13" iPad (required)** | iPad Pro 13" (M4) | 2064 × 2752 | 3–10 |

The build targets **iPhone + iPad** (TARGETED_DEVICE_FAMILY = 1,2), so
Apple requires at least one iPad screenshot size. The 13" size cascades
down to smaller iPads automatically.

## The five screens we ship in v1

Captured in this exact order so the App Store carousel tells a story:

1. **Home / Learn tab** — the streak counter at full glory, 3 language cards
   on screen. *Caption overlay: "Real code. Bite-size lessons."*
2. **Lesson view (mid-lesson)** — a completed checkpoint visible, XP visible.
   *Caption: "Swift, Python, HTML — all in one app."*
3. **Progress tab / language tree** — unlocked path visible, concept tags.
   *Caption: "See exactly what they're learning."*
4. **Paywall with the parental gate** — star button + progress ring filling.
   *Caption: "Parent-gated. Kid-safe."*
5. **Parent Dashboard (PIN-unlocked state)** — concept summary chips + daily
   goal stepper visible.
   *Caption: "A dashboard built for parents, not kids."*

## Capture script

Run from the repo root. Boots an iPhone 17 Pro Max simulator, installs a
Debug build, screenshots the current screen, and saves to
`submission/screenshots/6.9/`.

```bash
./submission/capture-screenshots.sh
```

Rerun for each additional size by passing `DEVICE` inline:

```bash
DEVICE="iPhone 11 Pro Max" ./submission/capture-screenshots.sh   # 6.5"
DEVICE="iPad Pro 13-inch (M4)" ./submission/capture-screenshots.sh  # 13" iPad
``` The script handles the
simctl dance but you'll still have to tap through the app to reach each
target screen before it snaps — that's intentional, App Review wants real
app state, not mocked UI.

## Marketing overlays (Figma)

Apple accepts "screenshots with text overlays" as long as the app UI is the
dominant element. Suggested Figma layout:

- Device frame: Apple's official iPhone 17 Pro Max mockup
  (downloadable free from developer.apple.com/design/resources/)
- Overlay text: top 25% of frame, Nunito 900 at 96pt, white on
  Spark→Indigo gradient bar
- Brand mark: bottom-right, 80pt, 70% opacity

## Submitting

1. Open App Store Connect → App → **Previews and Screenshots**
2. Select **6.9" Display**, drag in all 5 PNGs in carousel order
3. Repeat for **6.5" Display**
4. Save

**Common rejection:** raw simulator screenshots with the status bar showing
personal info (Wi-Fi name, carrier). The script below normalizes the status
bar to Apple's demo mode before capture.
