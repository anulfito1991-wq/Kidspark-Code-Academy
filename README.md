# ⚡ KidSpark Academy

An iOS coding learning app for kids (6–10) and teens (11–16), built with SwiftUI and SwiftData.

## Features

- **7 languages** — Blocks (Scratch-style), Swift, Python, JavaScript, HTML & CSS, Lua, Java
- **Tree-branch lesson path** per language with locked / available / completed node states
- **Hybrid lesson format** — explainer → multiple choice → code fill-in-blank → reward
- **XP, levels & streaks** with milestone coaching messages
- **Weekly challenges** rotating across all languages
- **Parent dashboard** with PIN protection and weekly activity charts
- **Local push notifications** — streak reminders and challenge alerts
- **Pro subscription** via StoreKit 2 (monthly & annual) unlocking Intermediate+ tiers
- **KidSpark Academy brand** — rounded typography, purple/spark color system

## Tech stack

| Layer | Technology |
|---|---|
| UI | SwiftUI (iOS 17+) |
| Persistence | SwiftData (`@Model`) |
| State | `@Observable` / `@Environment` |
| Monetisation | StoreKit 2 |
| Notifications | UNUserNotificationCenter (local only) |
| Content | Bundled JSON lesson files |

## Privacy

KidSpark Academy collects **no personal data**. All progress is stored on-device using SwiftData. No analytics, no advertising, no servers.

**Privacy Policy:** [kidspark.academy/privacy](https://your-github-username.github.io/kidspark-academy/)

## Requirements

- Xcode 15+
- iOS 17.0+ deployment target
- Swift 5.9+

## Project structure

```
Code app for kids/
├── App/                    # Entry point, brand system (KidSparkBrand.swift)
├── Catalog/                # Language, Lesson, Badge definitions
├── Models/                 # SwiftData models (Learner, LessonProgress, Challenge)
├── Services/               # AppState, XPService, StreakService, BadgeService…
├── Views/
│   ├── Components/         # Reusable UI (XPBar, ChallengeCard, LessonNodeView…)
│   └── Lesson/             # Step views (Explainer, MCQ, CodeFill, Reward)
└── Resources/
    └── Lessons/            # swift.json, python.json, javascript.json…
docs/                       # GitHub Pages — privacy policy
```

## License

Copyright © 2026 KidSpark Academy. All rights reserved.
