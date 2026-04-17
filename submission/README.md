# KidSpark Academy — Submission Package

Everything you need to ship v1.0 to the App Store.

## Read in this order

1. **`01-app-store-copy.md`** — paste-ready text for every App Store Connect field.
2. **`02-screenshots-plan.md`** — how to capture the 5 required screenshots.
3. **`03-compliance-sweep.md`** — final audit against App Review guidelines. Has 1 small amber decision for you.
4. **`04-category-decision.md`** — Kids vs Education memo. Recommendation: **Education**.
5. **`05-owner-checklist.md`** — the step-by-step you execute personally (3–5 hours active work).

## Helper script

- **`capture-screenshots.sh`** — boots the simulator, builds, normalizes the
  status bar, and snaps screenshots on ENTER. Run from repo root.

## Status at a glance

| Area | Status |
|---|---|
| Code-side App Review compliance | ✅ Green |
| Hosted Privacy + Terms | ✅ Live |
| App Icon (all 13 slots) | ✅ Shipped (first-pass SVG; polish optional) |
| ASC copy | ✅ Drafted |
| Screenshots | ⏳ Owner to capture (script ready) |
| Apple Developer enrollment | ⏳ Owner |
| Subscription products in ASC | ⏳ Owner |
| TestFlight sandbox purchase | ⏳ Owner |
| Submit for review | ⏳ Owner |

## One decision that blocks progress

See `03-compliance-sweep.md` section **A1**: `SUPPORTED_PLATFORMS` currently
includes macOS + visionOS. Recommend restricting to iOS-only for v1. Tell me
"iPhone only" and I'll make the edit.
