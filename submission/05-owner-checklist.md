# KidSpark Academy — Owner Checklist

Everything the owner (Anulfito) has to do personally. I cannot do these —
they require your Apple ID, banking info, or physical device.

Estimated total time: **3–5 hours of active work**, plus 24–72 h of
waiting on Apple enrollment + Paid Apps Agreement propagation.

---

## Phase 1 — Developer account ($99, ~10 min + 24–48 h wait)

- [ ] Enroll in **Apple Developer Program** at https://developer.apple.com/programs/
  - Individual or Organization — Individual is faster; Organization takes
    an extra ~2 weeks for D-U-N-S verification but publishes under a
    company name instead of your personal one.
- [ ] Wait for confirmation email (typically 24–48 h).

## Phase 2 — App Store Connect setup (~60 min, once enrolled)

- [ ] Sign in at https://appstoreconnect.apple.com
- [ ] Agreements, Tax, and Banking:
  - [ ] **Paid Apps Agreement** — accept
  - [ ] **Banking** — add payout bank account
  - [ ] **Tax** — complete W-9 (US) or W-8BEN (non-US)
- [ ] Create the app:
  - Platforms: **iOS** (covers both iPhone and iPad — single checkbox)
  - Name: **KidSpark Academy: Kids Code**
  - Primary Language: English (U.S.)
  - Bundle ID: **com.kidspark.academy** (pick from dropdown; register as an App ID first if missing)
  - SKU: `kidspark-academy-001`

## Phase 3 — Paste the copy pack (~30 min)

Open `submission/01-app-store-copy.md` and paste each field into the
corresponding ASC field:

- [ ] App Information → Subtitle, Primary Category (Education), Age Rating 4+
- [ ] Pricing and Availability → Free, all territories
- [ ] App Privacy → **Data Not Collected** for every category
- [ ] Prepare for Submission (per version):
  - [ ] Promotional Text
  - [ ] Description
  - [ ] Keywords
  - [ ] Support URL + Marketing URL
  - [ ] What's New
  - [ ] App Review Information — notes for the reviewer (verbatim from copy pack)
  - [ ] Contact Information (your name + kidspark.academy.learning@gmail.com)
  - [ ] Version release: **Manually release this version**
  - [ ] Content Rights: **Does not contain third-party content**
  - [ ] Advertising Identifier: **Does not use IDFA**

## Phase 4 — Subscriptions (~30 min)

In ASC → Monetization → Subscriptions:

- [ ] Create Subscription Group: **KidSpark Academy Pro**
- [ ] Add Subscription — Monthly (`com.kidspark.academy.pro.monthly`, Tier 5)
  - Display name + description from copy pack
  - Upload Paywall screenshot as the review screenshot
- [ ] Add Subscription — Annual (`com.kidspark.academy.pro.annual`, Tier 40)
  - Display name + description from copy pack
  - Upload Paywall screenshot
- [ ] Add the parental-gate review note to **both** products (copy pack → Subscription section)

## Phase 5 — Screenshots (~45 min)

- [ ] Run: `./submission/capture-screenshots.sh` (6.9" iPhone)
- [ ] Tap through the 5 target screens in order (see `02-screenshots-plan.md`)
- [ ] Repeat with `DEVICE="iPhone 11 Pro Max"` (6.5" iPhone)
- [ ] Repeat with `DEVICE="iPad Pro 13-inch (M4)"` (13" iPad — required because we target iPad)
- [ ] *(Optional but recommended)* Drop them into your Figma + add overlays
- [ ] Upload to ASC → App Store tab → Previews and Screenshots (one batch per size)

## Phase 6 — App Icon final polish (optional but nice)

- [ ] Polish the 1024 variants in Figma (light, dark, tinted)
- [ ] Export 3 PNGs at 1024×1024
- [ ] Save to:
  ```
  Code app for kids/Code app for kids/Assets.xcassets/AppIcon.appiconset/
      AppIcon-iOS-Light-1024.png
      AppIcon-iOS-Dark-1024.png
      AppIcon-iOS-Tinted-1024.png
  ```
- [ ] Tell me when ready — I'll re-run the Mac size generator and confirm
      the catalog still compiles.

## Phase 7 — Device test (~30 min)

- [ ] Install a Debug build on a **real iPhone** via Xcode
- [ ] *(If you own one)* also install on a real **iPad** — build now targets iPad too
- [ ] Sanity check on each device:
  - [ ] Icon renders correctly on home screen
  - [ ] Age gate flows properly
  - [ ] Complete a lesson, earn XP, see streak update
  - [ ] Set a Parent PIN, access dashboard
  - [ ] Tap Pro tab — confirm the press-and-hold gate works on real touch
  - [ ] Enable reminders from dashboard — real notification permission dialog appears
  - [ ] On iPad: check layout in both portrait + landscape; Split View if you use it

## Phase 8 — TestFlight (~45 min + 24 h Apple processing)

- [ ] Bump `CURRENT_PROJECT_VERSION` to `2` in Xcode (only `MARKETING_VERSION` stays `1.0`)
- [ ] Product → Archive → Distribute App → App Store Connect → Upload
- [ ] Wait for Apple processing (usually 15–60 min, sometimes up to 24 h)
- [ ] Create an internal testing group in TestFlight; add yourself
- [ ] Install TestFlight build on your iPhone
- [ ] Create a **Sandbox Apple ID** (ASC → Users and Access → Sandbox Testers)
- [ ] Sign into the sandbox account on your test iPhone (Settings → App Store → Sandbox)
- [ ] Test purchase flow for BOTH subscriptions:
  - [ ] Monthly purchase → app shows Pro status
  - [ ] Restore purchase → works from a fresh reinstall
  - [ ] Cancel via Settings → Subscriptions → state reverts after renewal date

## Phase 9 — Submit for review (~5 min)

- [ ] ASC → App Store tab → **Submit for Review**
- [ ] Answer final compliance questions (all answers are in the copy pack)
- [ ] Submit

## Phase 10 — Waiting (24–72 h)

- [ ] Monitor the Resolution Center in ASC
- [ ] If rejected: read the reviewer message; most rejections at this stage are
      metadata-only and resolvable in <1 hour. Respond in the Resolution Center.
- [ ] On approval: if you picked "Manually release this version", click **Release**.

---

## Shortcuts if you want to cut corners (not recommended, but)

| Corner | Risk |
|---|---|
| Skip TestFlight, submit directly | Broken purchase flow = certain rejection + 48 h lost |
| Use my SVG-rendered icon as-is | App Review will approve. App Store page conversion will be ~30% lower than a polished icon |
| Skip the 6.5" screenshots if only uploading 6.9" | Allowed since 2024 — cascade works. Cut it. |
| Use AI-generated screenshots | Apple bans "mockups that don't reflect the actual app". Real simulator captures only. |

---

## Once you're live

- [ ] Email yourself `kidspark.academy.learning@gmail.com` from a different
      address to confirm the inbox still works.
- [ ] Set up a simple auto-responder acknowledging receipt (Gmail Settings →
      General → Vacation Responder, or a Filter).
- [ ] Add the App Store URL to https://anulfito1991-wq.github.io/Kidspark-Code-Academy/
      once live (I'll wire it in when you give me the URL).
- [ ] Celebrate. 🚀
