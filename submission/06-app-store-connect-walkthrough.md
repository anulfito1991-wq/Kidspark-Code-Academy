# App Store Connect — Step-by-step Walkthrough

This is the hands-on sequence to create the app record and the two
subscription products. Follow top-to-bottom. Every field value you need is
in this doc or in `01-app-store-copy.md`.

Time estimate: **45–60 minutes**, most of which is waiting for Apple's
tax/banking forms to clear and copy-pasting fields.

**Prerequisites (do these first or you'll be blocked):**

- [ ] Apple Developer Program enrollment active ($99/yr). Sign in at
      <https://developer.apple.com/account> and confirm "Active" status.
- [ ] Paid Apps Agreement signed in App Store Connect → Business →
      Agreements, Tax, and Banking. **Without this, subscription products
      cannot be created.**
- [ ] Tax forms (W-9 if US) and banking info complete.
- [ ] You are signed in to <https://appstoreconnect.apple.com> with the
      Account Holder or Admin role.

---

## Phase 1 — Create the app record

1. Go to **Apps** → **+ (New App)**.
2. Fill in:
   - **Platform:** iOS
   - **Name:** `KidSpark Code Academy`
   - **Primary Language:** English (U.S.)
   - **Bundle ID:** `com.kidspark.academy` (select from the dropdown — it
     must already exist in the Developer Portal as an App ID. If it
     doesn't, create it at <https://developer.apple.com/account/resources/identifiers/list>
     first, then come back.)
   - **SKU:** `kidspark-academy-v1` (internal; any unique string)
   - **User Access:** Full Access
3. Click **Create**.

---

## Phase 2 — Fill the app information page

On the left sidebar: **App Information**.

- **Category → Primary:** Education
- **Category → Secondary:** *leave blank* (or "Games → Educational" if you
  want cross-discovery; see `04-category-decision.md`)
- **Content Rights:** ☐ (unchecked — we own everything)
- **Age Rating:** click **Edit** → every question **No** → age rating
  will auto-set to **4+**
- **Privacy Policy URL:** `https://anulfito1991-wq.github.io/Kidspark-Code-Academy/`

Save.

---

## Phase 3 — Create the subscription group

Sidebar → **Subscriptions** (under Monetization).

1. Click **+** next to Subscription Groups.
2. **Reference Name:** `KidSpark Academy Pro`
3. Click **Create**.
4. On the new group page, under **Localizations**, click **+** → English (U.S.):
   - **Subscription Group Display Name:** `KidSpark Academy Pro`
   - Save.

---

## Phase 4 — Create Product 1: Monthly ($4.99)

Still inside the `KidSpark Academy Pro` group, click **Create Subscription**.

### Identification

- **Reference Name:** `KidSpark Pro Monthly`
- **Product ID:** `com.kidspark.academy.pro.monthly`

Click **Create**. Now fill the rest of the fields on the product page:

### Subscription Duration

**1 Month**

### Subscription Pricing

- Click **+** → **Add Subscription Price**.
- Base country: **United States**.
- Price: **USD $4.99** (Apple will auto-calculate price tiers for all other
  territories — accept the defaults unless you have a specific plan for
  certain markets).
- Start date: today. No end date.
- Save.

### App Store Localization (English U.S.)

- **Display Name:** `KidSpark Pro Monthly`
- **Description:** `Unlock every intermediate and advanced lesson across all 7 languages. 2× XP. Cancel anytime.`
- Save.

### Review Information

- **Screenshot:** upload the Paywall screenshot (you'll capture this in
  Phase 7 — come back here then).
- **Review Note:**
  ```
  Subscribe button is gated by a 3-second press-and-hold on the star icon.
  This is the Kids Category parental gate per Guideline 1.3. Hold the star
  until the progress ring fills, then Subscribe / Restore become active.
  ```

Status should now be **Ready to Submit** or **Missing Metadata** depending
on whether the screenshot is uploaded. Proceed to Product 2 — add the
screenshot later.

---

## Phase 5 — Create Product 2: Annual ($39.99)

Back in the subscription group, click **Create Subscription** again.

### Identification

- **Reference Name:** `KidSpark Pro Annual`
- **Product ID:** `com.kidspark.academy.pro.annual`

### Subscription Duration

**1 Year**

### Subscription Pricing

- Price: **USD $39.99**
- Start date: today. No end date.

### App Store Localization (English U.S.)

- **Display Name:** `KidSpark Pro Annual`
- **Description:** `Best value — save 33%. Every intermediate and advanced lesson, all 7 languages, 2× XP.`

### Review Information

- Screenshot: same Paywall screenshot.
- **Review Note:** same as monthly.

### ⚠️ Subscription Ranking (important)

Back at the group level, you'll see both products listed with a **Level**
column. Drag so that:

- **Level 1:** `KidSpark Pro Annual` (higher value)
- **Level 2:** `KidSpark Pro Monthly` (lower value)

This tells StoreKit the Annual is an *upgrade* from Monthly and the
Monthly is a *downgrade* from Annual. Apple handles prorated refunds
automatically on switches.

---

## Phase 6 — Group-level legal URLs

On the subscription group page, look for **Subscription Privacy Policy
URL** and **Terms of Use URL** (required).

- **Privacy Policy URL:** `https://anulfito1991-wq.github.io/Kidspark-Code-Academy/`
- **Terms of Use URL:** `https://anulfito1991-wq.github.io/Kidspark-Code-Academy/terms.html`

These show in the system purchase sheet and in the App Store listing.

---

## Phase 7 — Sandbox test the full purchase flow

Do this **before** filling out the rest of the app submission. If a
sandbox purchase fails, you want to discover it now, not after Apple
rejects.

1. **App Store Connect → Users and Access → Sandbox Testers → +**.
   - Create a throwaway email (it doesn't need to be real, e.g.
     `kidspark-sandbox-1@icloud.com`). Set a password you'll remember.
   - Country/region: United States.
2. On a physical iPhone (sandbox purchases don't work in the simulator for
   StoreKit 2 subscriptions — they do for StoreKit Config files, but not
   for production products): **Settings → App Store → Sandbox Account →
   Sign In** with the sandbox tester you just created.
3. Build and run KidSpark Academy to the device from Xcode (or install via
   TestFlight once Phase 10 is done — whichever is faster).
4. In-app: **Pro tab → hold the star 3 seconds → tap Subscribe (Annual).**
   The sandbox sheet appears. Confirm. Expect the Subscribe CTA to change
   state and `hasPro` to flip on. Verify Pro lessons unlock and the Pro
   chip appears on the Home stats panel.
5. Repeat for Monthly.
6. **Test Restore** — delete the app, reinstall, tap Restore on the
   paywall. Pro state should come back.
7. **Test cancel** — Settings → Your Name → Subscriptions → KidSpark
   Academy Pro → Cancel. Sandbox accounts get accelerated renewal cycles
   (1 month = 5 minutes) so you can verify the downgrade path too.

If any of those steps fails, fix before submission — a broken purchase is
a guaranteed Guideline 2.1 rejection.

---

## Phase 8 — Capture the paywall screenshot for ASC

ASC needs one screenshot per subscription (we use the same for both).

1. Simulator: iPhone 16 Pro Max (6.9" — Apple's current required size).
2. Launch app → hold the parental gate star 3 seconds → fully-unlocked
   paywall visible.
3. ⌘S to save. The PNG lands on your Desktop.
4. Upload to both Monthly and Annual review screenshot slots in ASC.

Alternative: use `submission/capture-screenshots.sh` if you want the full
set of store screenshots at the same time.

---

## Phase 9 — Fill the remaining app submission fields

In App Store Connect, go to the **1.0 Prepare for Submission** page and
fill the rest:

- **App Previews and Screenshots:** upload from `02-screenshots-plan.md`
  (6.9" iPhone, 6.5" iPhone, 13" iPad Pro — 3–10 screenshots each).
- **Promotional Text, Description, Keywords, Support URL, Marketing URL:**
  paste from `01-app-store-copy.md`.
- **Version:** `1.0`
- **Copyright:** `2026 KidSpark Academy`
- **App Review Information:** paste notes from `01-app-store-copy.md`.
  - Sign-in required: **No**
  - Contact first/last name, phone, email: yours
- **Version Release:** Automatically release after approval (or manually
  if you want to coordinate a launch day).

---

## Phase 10 — Archive, upload, and pick the build

1. In Xcode: **Product → Archive** (requires a physical device or "Any iOS
   Device" selected, not a simulator).
2. When Organizer opens, select the archive → **Distribute App →
   App Store Connect → Upload**.
3. Answer **No** to "Does your app use encryption not exempt from export
   compliance?" (matches the `ITSAppUsesNonExemptEncryption = NO` key
   already set in the project).
4. Wait 10–30 minutes for Apple to finish processing.
5. Back in App Store Connect → `1.0 Prepare for Submission` → **Build**
   section → **+** → select the uploaded build.

---

## Phase 11 — Submit

Click **Add for Review** → confirm the answers on the content-rights and
advertising-identifier prompts → **Submit for Review**.

Typical review time: **24–48 hours** for a first submission. Apple will
email you at each state transition (In Review → Approved / Rejected).

If rejected, read the feedback carefully — the most common first-time
rejections are:

- Missing parental gate on a Kids-oriented paywall (we've handled this)
- Metadata mismatch (e.g. screenshots showing a feature that isn't
  actually in the build)
- "IAP not consumed/restored correctly" (Phase 7 catches this)

Fix, bump the build number (`Build: 2`), upload a new archive, reply to
the review comment, and re-submit. No re-upload fee.

---

## Rollback / edit paths

- **Subscription price change:** Subscription product → Subscription
  Pricing → edit. Existing subscribers are grandfathered unless you raise
  the price, in which case Apple asks each existing user to consent.
- **Description / keywords change:** editable at any time. **Promotional
  Text** is editable without resubmission — use it for marketing updates.
- **Bundle ID change:** NOT reversible. Do not change post-launch.
- **Subscription group move:** NOT reversible. Leave both SKUs in
  `KidSpark Academy Pro` forever.
