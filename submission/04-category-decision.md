# Kids vs Education — category memo

## TL;DR — Recommendation: **Education** (primary), no secondary.

KidSpark Academy meets every Kids Category rule we'd meet in Education
anyway, but the Kids Category locks in ongoing constraints we don't need
and subjects us to stricter, slower review each release. Education gives
us the same parent trust signal (Apple surfaces "Education" prominently),
broader search visibility, and zero friction to add cross-platform features
later (web companion, newsletter opt-in for parents, etc.) without
re-architecting.

## The two paths side-by-side

| Axis | Kids Category | Education Category |
|---|---|---|
| **Who it's for** | Age-banded 5 and under / 6–8 / 9–11 | Anyone learning anything |
| **Discovery** | Kids tab in App Store (small but curated) | "Education" chart + general search |
| **App Review intensity** | Stricter, slower, every release | Standard |
| **Third-party SDKs** | **Permanently prohibited** (any analytics, ads, tracking) | Allowed if disclosed |
| **External links** | Must open in in-app browser, not Safari | Normal rules |
| **Data collection** | Must be zero from kids without verified parental consent | Normal COPPA rules |
| **Ads / IAP** | IAP behind parental gate. Ads essentially forbidden. | Normal rules |
| **Perceived safety** | High — "Made for Kids" badge | Medium — parents still trust Education |
| **Ability to pivot** | Very restricted | Full flexibility |

## Why Education wins for KidSpark's roadmap

1. **We already meet every Kids rule voluntarily.** Data Not Collected. No
   SDKs. Parental gate on purchases. PIN on dashboard. Parents will see
   this clearly from the privacy labels + description — the Kids badge
   isn't required to communicate it.

2. **Kids locks the door behind you.** Six months from now if we want to
   add any analytics — even privacy-preserving Apple App Analytics counts
   in some Apple rulings — we'd have to re-submit as Education anyway.

3. **Submission velocity.** Kids Category apps go through a slower review
   track. For a rapidly iterating v1/v1.1/v1.2 launch cadence this costs
   real days per release.

4. **Search surface area.** "Education" is a far larger search cluster
   than the Kids tab. Our keywords (kids coding, learn to code, python
   for kids) index naturally in Education. In Kids, ranking depends
   heavily on editorial curation, which takes time to earn.

5. **Brand posture.** "Kids Category" can read as "babysitter app."
   "Education" reads as serious learning tool. Our positioning — real
   programming languages, concept-tagged lessons, parent dashboard —
   leans serious.

## When Kids Category would be the better call

- If the product strategy depends on editorial features (Apple's "Great
  for Kids" rotating collections) more than paid/organic growth.
- If you plan to add no analytics ever, including SKAdNetwork attribution
  for future paid acquisition.
- If the under-5 age band is the primary target. (It isn't — we target 6–12.)

Neither is true for us. Go Education.

## Action for App Store Connect

- **Primary Category:** Education
- **Secondary Category:** *(leave blank)*
- **Age Rating:** 4+
- **Made for Kids:** **No** (this is the explicit opt-out of the Kids Category)

If you change your mind later: switching **Education → Kids** requires a new
app submission. Switching **Kids → Education** is trivial (it's a privilege
reduction Apple allows inline).
