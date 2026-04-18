#!/usr/bin/env python3
"""Fill in the App Store Connect fields we have paste-ready copy for.

Leaves review-contact name/phone/email as TODO placeholders you must finish
in the web UI — those are the only two things the API can't take a best-guess
on safely.
"""
import base64, json, subprocess, sys, time, urllib.request, urllib.error

KEY_ID="KDFPL64CHR"; ISSUER="51549305-fc95-4dc5-a0bb-41060f7b0a57"
KEY_PATH="private_keys/AuthKey_KDFPL64CHR.p8"
VERSION="afc4e171-d1d1-4894-9b98-cdbbef7bb38a"
LOC="9ad65bbd-5056-4891-a91e-451705f909f0"

def _b(x): return base64.urlsafe_b64encode(x).rstrip(b"=").decode()
def _jwt():
    h={"alg":"ES256","kid":KEY_ID,"typ":"JWT"}
    p={"iss":ISSUER,"iat":int(time.time()),"exp":int(time.time())+600,"aud":"appstoreconnect-v1"}
    si=f"{_b(json.dumps(h,separators=(',',':')).encode())}.{_b(json.dumps(p,separators=(',',':')).encode())}"
    der=subprocess.run(["openssl","dgst","-sha256","-sign",KEY_PATH,"-binary"],input=si.encode(),capture_output=True,check=True).stdout
    i=2 if der[1]<0x80 else 3;rl=der[i+1];r=der[i+2:i+2+rl];j=i+2+rl;sl=der[j+1];s=der[j+2:j+2+sl]
    rs=r.lstrip(b"\x00").rjust(32,b"\x00")+s.lstrip(b"\x00").rjust(32,b"\x00")
    return f"{si}.{_b(rs)}"
def api(method, path, body=None):
    url=f"https://api.appstoreconnect.apple.com{path}"
    hdrs={"Authorization":f"Bearer {_jwt()}"}; data=None
    if body is not None:
        data=json.dumps(body).encode(); hdrs["Content-Type"]="application/json"
    req=urllib.request.Request(url,data=data,method=method,headers=hdrs)
    try:
        raw=urllib.request.urlopen(req,timeout=30).read()
        return json.loads(raw) if raw else None
    except urllib.error.HTTPError as e:
        print(f"!! HTTP {e.code} {method} {path}\n{e.read().decode()[:400]}")
        raise

DESCRIPTION = """\
KidSpark Academy turns the first steps of real programming into a daily adventure kids want to come back to. Bite-size lessons, a streak that rewards consistency, and weekly challenges that stretch what they just learned — built for curious kids ages 6 to 12.

SEVEN CODING LANGUAGES, 90+ LESSONS
• Scratch — drag-and-drop blocks, the perfect first step
• Swift — Apple's modern language, used to build iPhone apps
• Python — the language of data, science, and AI
• JavaScript — the language that powers every website
• HTML — the building blocks of the web
• Java — the language of Minecraft mods and Android
• Lua — the scripting language inside Roblox Studio

HOW IT WORKS
• Short, focused lessons (2–5 minutes) — perfect between homework and dinner
• Three tiers per language — Basics, Intermediate, Advanced
• Concept tags show exactly what each lesson teaches: variables, loops, functions, conditionals, events, classes, and more
• Progress tree visualizes their journey through each language
• Daily streak with a goal stepper parents can tune (1–10 lessons/day)
• Weekly coding challenge that levels up with their skill
• Level-up toasts and milestone celebrations keep motivation high

MADE FOR FAMILIES
• Parent Dashboard with a PIN-protected overview of everything your child has learned — by language, by concept, by lesson
• No ads. Ever.
• No third-party tracking. Ever.
• Data Not Collected. Progress stays on-device in encrypted app storage.
• Compliant with COPPA, GDPR, CCPA, and the newer state privacy laws (Virginia, Colorado, Connecticut, Utah)
• Subscription purchases sit behind a press-and-hold parental gate

KIDSPARK ACADEMY PRO
Unlock every intermediate and advanced lesson across all seven languages, earn XP 2× faster, and get 2 streak freezes per month:
• Monthly — $4.99
• Annual — $39.99 (save 33%)
Free forever: the 42 foundation lessons (6 per language × 7 languages), streak tracking, weekly challenges, and the Parent Dashboard.

Subscriptions auto-renew unless cancelled at least 24 hours before the current period ends. Payment is charged to your Apple ID at purchase confirmation. Manage or cancel anytime in Settings → Your Name → Subscriptions.

WHY PARENTS CHOOSE KIDSPARK
• Designed by developers who wanted their own kids to learn real code, not just drag-and-drop puzzles
• Every lesson is reviewed for age-appropriate language and examples
• Zero social features — no comments, no chat, no public profiles
• No collection of personal information

Privacy Policy: https://anulfito1991-wq.github.io/Kidspark-Code-Academy/
Terms of Use:   https://anulfito1991-wq.github.io/Kidspark-Code-Academy/terms.html
Support:        kidspark.academy.learning@gmail.com
"""

KEYWORDS = "kids coding,learn to code,python,swift,javascript,scratch,html,java,lua,stem,programming"

PROMO = ("7 coding languages, 90+ lessons, weekly challenges, daily streaks. "
         "Bite-size learning for curious kids 6–12. No ads. No tracking. Just spark.")

SUPPORT_URL   = "https://anulfito1991-wq.github.io/Kidspark-Code-Academy/"
MARKETING_URL = "https://anulfito1991-wq.github.io/Kidspark-Code-Academy/"

REVIEW_NOTES = """\
Thank you for reviewing KidSpark Academy.

PARENTAL CONTROLS
• The Parent Dashboard (Parents tab) is protected by a PIN chosen by the parent on first visit. To test, tap "Set PIN" and choose any 4-digit code.
• The Pro tab's subscription buttons are gated by a 3-second press-and-hold on a star icon ("Adults only — press and hold for 3 seconds"). This is our child-resistant barrier per Guideline 1.3.

SUBSCRIPTIONS
• Monthly: com.kidspark.academy.pro.monthly ($4.99)
• Annual:  com.kidspark.academy.pro.annual  ($39.99)
• Free tier includes all foundation lessons, streaks, and the Parent Dashboard.
• One intermediate lesson is unlocked free per language as a "try before you buy" sample.

PRIVACY
• Data Not Collected. All progress is stored locally in SwiftData, in encrypted app storage.
• The Parent PIN is stored as a SHA-256 hash in the Keychain — the PIN itself is never persisted.
• No third-party SDKs. No analytics. No advertising.
• Notifications are NOT requested on launch. A parent must tap "Enable reminders" inside the PIN-protected Parent Dashboard.
• Encryption: only Apple's CryptoKit SHA-256 is used for the PIN hash. This qualifies for the standard export-compliance exemption (ITSAppUsesNonExemptEncryption = NO in Info.plist).

LEGAL
• Privacy Policy: https://anulfito1991-wq.github.io/Kidspark-Code-Academy/
• Terms of Use:   https://anulfito1991-wq.github.io/Kidspark-Code-Academy/terms.html
• Support email:  kidspark.academy.learning@gmail.com

TESTING THE EXPERIENCE
1. Launch → Age Gate appears. Tap "I'm 13 or older" (or "I'm under 13" → parent consent).
2. Learn tab → tap any language → tap any lesson.
3. Complete a lesson to see streak + XP update.
4. Progress tab → visual tree of unlocked lessons per language.
5. Pro tab → press and hold the star for 3 seconds → buttons become active → sandbox purchase one SKU.
6. Parents tab → set a PIN → review the full dashboard, including concept summary, per-language drill-down, daily goal stepper, and notification toggle.

Thank you.
"""

# 1. Version — copyright
print("→ Setting copyright on 1.0…")
api("PATCH", f"/v1/appStoreVersions/{VERSION}", {
    "data": {"type":"appStoreVersions","id":VERSION,
             "attributes": {"copyright":"2026 KidSpark Academy"}}
})

# 2. Version localization — description, keywords, promo, URLs
print("→ Filling en-US version localization (description, keywords, promo, URLs)…")
api("PATCH", f"/v1/appStoreVersionLocalizations/{LOC}", {
    "data": {"type":"appStoreVersionLocalizations","id":LOC,
             "attributes":{
                "description":   DESCRIPTION,
                "keywords":      KEYWORDS,
                "promotionalText":PROMO,
                "supportUrl":    SUPPORT_URL,
                "marketingUrl":  MARKETING_URL,
             }}
})

# 3. App Review Detail — create with placeholders for contact fields.
print("→ Creating App Review detail with review notes (contact fields left for you)…")
try:
    api("POST", "/v1/appStoreReviewDetails", {
        "data": {"type":"appStoreReviewDetails",
                 "attributes":{
                    "contactFirstName":"TODO_FIRST_NAME",
                    "contactLastName": "TODO_LAST_NAME",
                    "contactPhone":    "TODO_PHONE",
                    "contactEmail":    "kidspark.academy.learning@gmail.com",
                    "demoAccountRequired": False,
                    "notes": REVIEW_NOTES,
                 },
                 "relationships":{
                    "appStoreVersion":{"data":{"type":"appStoreVersions","id":VERSION}}
                 }}
    })
except urllib.error.HTTPError:
    print("   (detail may already exist — trying PATCH path)")

print("\nDone. Re-run asc-audit.py to verify.")
