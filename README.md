# NihonGo Master 🇯🇵

**A comprehensive Japanese-learning mobile app built with Flutter** — kana, kanji, vocabulary, grammar, reading, JLPT mock tests, and AI-assisted speaking / pronunciation / writing practice, with an offline-first data layer and Firebase sync.

> 📚 Course project for **Mobile Application Development** (Lập trình cho thiết bị di động) — Faculty of Information Technology, **Phenikaa University**, cohort K17 (2023–2027). Built by a **team of 2 students**.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-%3E%3D3.0.0-0175C2?logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%2B%20Firestore-FFCA28?logo=firebase&logoColor=black)
![Platform](https://img.shields.io/badge/Platform-iOS%20%C2%B7%20Android%20%C2%B7%20Web%20%C2%B7%20Desktop-lightgrey)

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Data & Storage](#data--storage)
- [Screenshots](#screenshots)
- [Known Limitations](#known-limitations)
- [Roadmap](#roadmap)
- [Team & Credits](#team--credits)
- [Tóm tắt tiếng Việt](#tóm-tắt-tiếng-việt)
- [日本語サマリー](#日本語サマリー)

---

## Overview

Learning Japanese as a Vietnamese speaker usually means juggling several disconnected tools: one app for kana, a website for JLPT quizzes, a flashcard app for vocabulary, and a notebook for grammar. **NihonGo Master brings all of these into a single mobile app**, and keeps working when the network drops.

The app was designed around three practical problems:

| Problem | How this project addresses it |
|---|---|
| Learners lose momentum because study tools are fragmented | One app covering kana → kanji → vocabulary → grammar → reading → JLPT mock tests |
| Mobile networks are unreliable, so cloud-only apps break mid-session | Offline-first: SQLite cache + local seed data, with Firestore sync as an enhancement, not a requirement |
| Speaking and writing are the hardest skills to self-assess | AI-assisted practice screens for listening, pronunciation and writing, using TTS + speech recognition + on-device OCR |

### At a glance

| Metric | Value |
|---|---|
| Dart source files in `lib/` | **60** |
| Total Dart lines | **~23,900** |
| Lines excluding bundled learning content (`lib/data/`) | **~20,600** |
| Bundled learning content (`lib/data/`) | **~3,200 lines** |
| Screens | **23** |
| Data models | **11** |
| State providers | **6** |
| Services | **10** |
| Declared dependencies | **28** runtime + 2 dev |

---

## Features

### 📖 Learning content

- **Kana** — hiragana & katakana practice with stroke-order style drill screens
- **Kanji** — browse and study kanji with readings and meanings
- **Vocabulary** — organised by JLPT level (N5 → N1), backed by a searchable dictionary screen
- **Grammar** — grammar points with explanations and example sentences
- **Reading** — graded reading materials with comprehension practice
- **JLPT mock tests** — full question sets with automatic scoring and per-question correct/incorrect review

### 🎯 Practice & assessment

- **Flashcards** with **spaced repetition** — flip-card UI and a scheduling algorithm that revisits cards you get wrong
- **Vocabulary quiz**, **notebook quiz** and **word-matching** game modes
- **Listening practice** — audio playback with comprehension questions
- **Pronunciation practice** — speech recognition compares the learner's voice to the target
- **Writing practice** — on-device handwriting/character recognition via Google ML Kit Text Recognition
- **Vocabulary notebook** — save words you struggled with and re-test them later

### 🏆 Motivation & gamification

- **XP system** with per-action rewards (learning a word, passing a quiz, hitting a streak)
- **8 user levels** from *Người mới bắt đầu* to *Đại sư tiếng Nhật*, each with its own icon
- **Achievements** unlocked by milestones, with XP bonuses
- **Study streaks** and a **daily goal** setting
- **Leaderboard** screen for comparing progress
- **Progress dashboard** with charts, plus a full **study history** log
- Polish layer: animated transitions, confetti on completion, shimmer loading states, Lottie animations

### 👤 Accounts & accessibility

- Email/password **sign up, log in and password reset**
- **Google Sign-In** and **Facebook Login** (via `google_sign_in` + `flutter_facebook_auth`)
- **Guest/demo mode** — the app runs and can be demonstrated without a live Firebase project
- **Light / dark theme** toggle, persisted across launches
- **Japanese text-to-speech** for vocabulary and example sentences
- **Daily study reminder** as a local notification (scheduled for 20:00)
- Background music and sound effects (correct / wrong / skip / complete)

---

## Tech Stack

Versions below are taken directly from the project's `pubspec.yaml`.

### Core

| Package | Version | Role |
|---|---|---|
| `flutter` | SDK | UI framework for iOS / Android / Web / Desktop |
| `provider` | `^6.1.1` | State management |
| `shared_preferences` | `^2.2.2` | Small persisted settings (theme, streak, XP, daily goal) |
| `sqflite` | `^2.3.2` | Local SQLite database for offline content cache |
| `path` / `path_provider` | `^1.9.0` / `^2.1.5` | Filesystem paths for the local database |

### Backend & authentication

| Package | Version | Role |
|---|---|---|
| `firebase_core` | `^3.13.0` | Firebase bootstrap |
| `firebase_auth` | `^5.5.2` | Account authentication |
| `cloud_firestore` | `^5.6.6` | Cloud sync of user progress and shared content |
| `google_sign_in` | `^6.3.0` | Google login |
| `flutter_facebook_auth` | `^7.1.2` | Facebook login |
| `app_links` | `^7.0.0` | Deep-link handling for the OAuth redirect flow |

### Input, output & device capabilities

| Package | Version | Role |
|---|---|---|
| `flutter_tts` | `^4.2.2` | Japanese text-to-speech |
| `speech_to_text` | `^6.6.2` | Pronunciation checking |
| `google_mlkit_text_recognition` | `^0.13.0` | On-device character recognition for writing practice |
| `flutter_local_notifications` + `timezone` | `^19.1.0` + `^0.10.1` | Scheduled daily study reminders |
| `audioplayers` | `^6.0.0` | BGM and sound effects |

### UI, animation & visualisation

| Package | Version | Role |
|---|---|---|
| `fl_chart` | `^0.68.0` | Progress charts |
| `percent_indicator` | `^4.2.3` | Completion rings / bars |
| `flip_card` | `^0.7.0` | Flashcard flip animation |
| `lottie` | `^3.1.0` | Vector animations |
| `confetti` | `^0.7.0` | Celebration effect |
| `animate_do` | `^3.3.4` | Declarative entrance animations |
| `flutter_staggered_animations` | `^1.1.1` | Staggered list animations |
| `shimmer` | `^3.0.0` | Loading skeletons |
| `google_fonts` | `^6.2.1` | Typography |
| `intl` | `^0.19.0` | Date & number formatting |
| `uuid` | `^4.3.3` | Identifier generation |

**Dev dependencies:** `flutter_test`, `flutter_lints ^3.0.1`

---

## Architecture

The codebase follows a lightweight **MVVM-style separation** built on `provider`:

```
UI (screens/ + widgets/)  ──watches──▶  Providers (ChangeNotifier)
                                              │
                                              ▼
                                       Services (auth, firestore,
                                       sqlite, tts, notification, ai)
                                              │
                                              ▼
                                       Models (plain data classes)
```

**Layers**

| Layer | Responsibility |
|---|---|
| `lib/screens/` | Feature screens and user flows (23 files) |
| `lib/widgets/` | Reusable UI components |
| `lib/providers/` | `ChangeNotifier` state holders — auth, vocabulary, flashcard, progress, settings, study history |
| `lib/services/` | Side-effectful logic isolated from the UI — Firebase, Firestore, SQLite, TTS, notifications, BGM, AI evaluation |
| `lib/models/` | Immutable data classes with `fromMap` / `toMap` mapping |
| `lib/data/` | Bundled learning content as Dart constants (vocabulary, kanji, grammar, reading, JLPT questions) |
| `lib/utils/` | Theme, colours and app-wide constants (XP rules, level table, achievement definitions) |

**Two design decisions worth calling out**

1. **Firebase is optional at runtime.** `FirebaseService.initialize()` guards the bootstrap, and `lib/firebase_options.dart` exposes a `configured` flag. This lets the app compile and run for a demo without a live backend — useful for coursework and for reviewers cloning the repo.
2. **The app degrades gracefully.** Data access tries Firestore first and falls back to the local SQLite cache and bundled seed data, so a dropped connection never blocks a study session.

---

## Getting Started

### Prerequisites

- **Flutter SDK** (stable channel) with **Dart `>=3.0.0 <4.0.0`**
- **Android Studio** (with an emulator) or **Xcode** for iOS
- A device or emulator with **Google Play services** — required by Google ML Kit

Check your setup:

```bash
flutter --version
flutter doctor
```

### 1. Clone the repository

```bash
git clone https://github.com/mfuongg/nihongo_master.git
cd nihongo_master
```

### 2. Install packages

```bash
flutter pub get
```

### 3. Firebase configuration

The app is written so it **compiles and runs without a real Firebase project** (guest/demo mode). To enable real authentication and cloud sync:

1. Create a project in the [Firebase Console](https://console.firebase.google.com/).
2. Register your Android / iOS app and download the config file
   (`google-services.json` into `android/app/`, `GoogleService-Info.plist` into `ios/Runner/`).
3. Open `lib/firebase_options.dart` and set `configured = true`, then fill in your project values.
4. Enable the **Email/Password**, **Google** and **Facebook** sign-in providers.
5. Create the Firestore collections referenced by the app:
   - `users`
   - `vocabularies`
   - `users/{uid}/flashcard_progress`
   - `users/{uid}/test_history`

### 4. Run

```bash
flutter clean
flutter pub get
flutter run -d android
```

To produce a release build:

```bash
flutter build apk --release
```

> ⚠️ The mobile-specific plugins (ML Kit, speech recognition, local notifications) need a real device or an emulator with Google Play services. Running on a plain browser target will not exercise those features.

---

## Project Structure

```text
lib/
├── main.dart                     # App entry point, provider registration, theme wiring
├── firebase_options.dart         # Firebase config with a `configured` safety flag
├── data/                         # Bundled learning content (~3,200 lines)
│   ├── vocabulary_data.dart
│   ├── kanji_data.dart
│   ├── grammar_data.dart
│   ├── reading_material_data.dart
│   └── jlpt_test_data.dart
├── models/                       # 11 data classes
│   ├── app_user.dart
│   ├── vocabulary.dart
│   ├── kanji.dart
│   ├── grammar.dart
│   ├── quiz.dart
│   ├── reading_material.dart
│   ├── flashcard_progress.dart
│   ├── user_progress.dart
│   ├── study_history.dart
│   ├── daily_task.dart
│   └── community_contribution.dart
├── providers/                    # 6 ChangeNotifier state holders
│   ├── auth_provider.dart
│   ├── vocabulary_provider.dart
│   ├── flashcard_provider.dart
│   ├── progress_provider.dart
│   ├── study_history_provider.dart
│   └── settings_provider.dart
├── services/                     # 10 service classes
│   ├── firebase_service.dart
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   ├── local_database_service.dart
│   ├── ai_practice_evaluator.dart
│   ├── tts_service.dart
│   ├── notification_service.dart
│   ├── bgm_service.dart
│   ├── feedback_audio_service.dart
│   └── community_contribution_service.dart
├── screens/                      # 23 screens
│   ├── onboarding/splash_screen.dart
│   ├── auth/                     # login, register, forgot password
│   ├── home/                     # home dashboard, leaderboard
│   ├── vocabulary/               # vocabulary, flashcard, notebook,
│   │                             # quiz, notebook quiz, word matching,
│   │                             # listening, pronunciation, writing
│   ├── kana/ · kanji/ · jlpt/ · grammar/ · read/ · dictionary/
│   ├── progress/                 # charts and study history
│   └── settings/
├── widgets/
│   └── community_contribution_section.dart
└── utils/
    ├── theme.dart                # Light / dark themes
    └── constants.dart            # XP rules, level table, achievements
```

---

## Data & Storage

| Store | Used for |
|---|---|
| **Bundled Dart constants** (`lib/data/`) | The offline baseline — vocabulary, kanji, grammar, reading passages and JLPT question sets ship with the app so it is usable immediately |
| **SQLite** (`sqflite`, via `local_database_service.dart`) | Local cache of content fetched from the cloud, so previously loaded material stays available offline |
| **SharedPreferences** | Small user settings — streak, XP, level, daily goal, dark mode, onboarding flag |
| **Cloud Firestore** | User profile, progress and test history, enabling sync across devices |

The read path is **Cloud Firestore → local SQLite cache → bundled seed data**, so a missing network connection degrades the experience instead of breaking it.

---

## Screenshots

> 📌 The repository's `assets/images/` folder is currently empty — screenshots have not been added yet. To finish this section, capture the app on a device, save the files into `assets/images/`, and replace the placeholders below.

| Home | Flashcard | Kanji |
|---|---|---|
| _add `home.png`_ | _add `flashcard.png`_ | _add `kanji.png`_ |

| JLPT test | Progress | Writing practice |
|---|---|---|
| _add `jlpt.png`_ | _add `progress.png`_ | _add `writing.png`_ |

---

## Known Limitations

Documented honestly so reviewers know the current state:

- **Screenshots not yet included** — the `assets/images/` directory is empty in this archive.
- **Automated tests are minimal** — the project currently ships only the default `test/widget_test.dart`; there is no meaningful test coverage of the learning logic yet.
- **Content depth is a starter set** — the bundled vocabulary, kanji, grammar and JLPT sets are sized for coursework, not for full N5–N1 coverage.
- **Firebase must be provisioned by the cloner** — the app runs in demo mode out of the box, but cloud sync requires your own Firebase project.
- **Mobile-focused** — although platform folders for web and desktop are present, the plugins the app relies on (ML Kit, speech recognition, notifications) are mobile capabilities, so the web target is not a supported path for the full feature set.
- **`assets/data/` is declared in `pubspec.yaml` but no longer used** — learning content was moved into Dart constants under `lib/data/`.

---

## Roadmap

- [ ] Add unit and widget tests for the spaced-repetition scheduler and quiz scoring
- [ ] Expand the bundled vocabulary and kanji sets toward full N5–N1 coverage
- [ ] Add screenshot and demo-video links to this README
- [ ] Migrate `firebase_options.dart` out of source control into a documented setup step
- [ ] Add a GitHub Actions workflow for `flutter analyze` and `flutter test`

---


**Third-party assets:** Noto Sans JP font, Lottie animations and audio files used under their respective licences. Learning content is original or adapted for coursework.

---

## License

No license file is included in this repository yet. If you intend to reuse this code, please contact the authors first. A formal licence (for example MIT) can be added on request.

---

## Tóm tắt tiếng Việt

**NihonGo Master** là ứng dụng học tiếng Nhật trên nền tảng Flutter, được thực hiện theo nhóm 2 sinh viên cho đồ án môn *Lập trình cho thiết bị di động* tại Đại học Phenikaa.

Ứng dụng gộp toàn bộ quá trình học vào một chỗ: Kana, Kanji, từ vựng theo cấp độ JLPT, ngữ pháp, bài đọc, đề thi thử JLPT, cùng các chế độ luyện tập như flashcard theo thuật toán lặp lại ngắt quãng, quiz, ghép từ, luyện nghe, luyện phát âm và luyện viết. Phần động lực học tập gồm hệ thống XP, 8 cấp độ người dùng, thành tích, chuỗi ngày học liên tiếp, bảng xếp hạng và biểu đồ tiến độ.

Về kỹ thuật, dự án dùng `provider` để quản lý trạng thái theo mô hình MVVM, `sqflite` để lưu nội dung học ngoại tuyến, `shared_preferences` cho cài đặt người dùng, và Firebase (Auth + Firestore) cho tài khoản và đồng bộ đám mây. Điểm đáng chú ý là ứng dụng **vẫn chạy được khi chưa cấu hình Firebase** nhờ cơ chế fallback về dữ liệu có sẵn trong app và cache SQLite.

```
60 file Dart · ~23.900 dòng code (chưa tính nội dung học) · 23 màn hình
```

---

## 日本語サマリー

**NihonGo Master** は、Flutter で開発した日本語学習アプリです。大学の「モバイルアプリ開発」科目における 2 名チームの課題として作成しました。かな・漢字・語彙（JLPT N5〜N1）・文法・読解・JLPT 模擬試験に加え、間隔反復式の単語カード、クイズ、聞き取り、発音、ライティングの練習機能を実装しています。XP・レベル・実績・連続学習日数・ランキングといった学習継続の仕組みも備えています。

技術面では `provider` による MVVM 構成、`sqflite` によるオフライン保存、Firebase（Authentication + Firestore）によるアカウント管理とクラウド同期を採用しました。**Firebase を未設定でも動作するフォールバック設計**になっており、アプリ内のデータと SQLite キャッシュから学習を継続できます。

```
Dart ファイル 60 件 · 約 23,900 行 · 画面数 23
```
