# 🌸 NihonGo Master - Ứng dụng học tiếng Nhật thông minh

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-2.18+-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Firebase-Auth%20%26%20Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase" />
  <img src="https://img.shields.io/badge/SQLite-Offline%20Cache-003B57?style=for-the-badge&logo=sqlite&logoColor=white" alt="SQLite" />
  <img src="https://img.shields.io/badge/ML_Kit-Text%20Recognition-4285F4?style=for-the-badge&logo=google&logoColor=white" alt="ML Kit" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License" />
</p>

<p align="center">
  <strong>Học tiếng Nhật mọi lúc mọi nơi – Vui vẻ, hiệu quả, có hệ thống! 🎌</strong>
</p>

> **NihonGo Master** là ứng dụng học tiếng Nhật đa nền tảng viết bằng **Flutter + Dart**, kết hợp sức mạnh của **Firebase**, **SQLite**, **ML Kit** và **hệ thống lặp lại ngắt quãng (SRS)** để mang đến trải nghiệm học tập hiện đại: vừa ghi nhớ lâu, vừa cảm thấy hào hứng mỗi ngày.

Không chỉ dừng lại ở một ứng dụng flashcard đơn thuần, **NihonGo Master** còn là một bài toán kỹ thuật đầy thú vị: xây dựng một hệ sinh thái học tập hoàn chỉnh (Frontend + Backend + Local Cache + AI Service) hoàn toàn bằng Flutter thuần, vận hành mượt mà trên cả Android, iOS và Web mà không cần phụ thuộc vào bất kỳ Game Engine hay thư viện đồ sộ nào.

---

## 👨‍💻 Thông tin sinh viên

Sản phẩm là **Đồ án môn học Lập trình Mobile**, được xây dựng bằng cả tâm huyết bởi:

- **Ngô Thị Minh Phương** *(MSSV: 23012156 — Phenikaa University)*
- **Giảng viên hướng dẫn:** ThS. Trịnh Thanh Bình *(theo tài liệu BAOCAOMOBILE.pdf)*

> 💖 Cảm ơn thầy và các bạn đã dành thời gian khám phá **NihonGo Master**. Chúc mọi người có hành trình chinh phục tiếng Nhật thật vui vẻ! 🌸

---

## 🎮 Trải nghiệm ngay (Live Demo)

> ⚠️ *Demo Web chưa được public – đang trong giai đoạn tối ưu build. Bạn có thể trải nghiệm nhanh bằng cách chạy local theo hướng dẫn cài đặt bên dưới.*

---

## 🔥 NHỮNG ĐIỂM SÁNG KỸ THUẬT (Technical Highlights)

Dự án không dùng Engine nào ngoài Flutter – toàn bộ được tự dựng:

- 🎨 **MVVM-lite với Provider:** Kiến trúc `Service ↔ ViewModel (ChangeNotifier) ↔ Screen` giúp tách bạch logic, dễ bảo trì và unit-test.
- ⚡ **State Management cục bộ hoá:** `provider` + `ChangeNotifier` đảm bảo hàng chục màn hình (Auth, Vocab, Flashcards, Leaderboard, AI Practice…) rebuild chính xác, không giật lag.
- ☁️ **Hybrid Storage (Cloud + Local):** `cloud_firestore` đồng bộ dữ liệu `users`, `vocabularies`, `flashcard_progress`, `test_history`; khi mất mạng, `sqflite` hoạt động như lớp cache offline – không bao giờ "đứng hình".
- 🧠 **Spaced Repetition System (SRS):** Thuật toán lặp lại ngắt quãng tự viết (xem trong `lib/services/srs_service.dart`), tính toán ngày ôn tập kế tiếp dựa trên độ khó và lịch sử trả lời.
- 🔊 **Text-to-Speech chuẩn Nhật:** `flutter_tts` phát âm chuẩn với locale `ja-JP`, tích hợp trực tiếp trong Flashcards và AI Practice.
- 🎙️ **AI Speaking (Speech-to-Text):** `speech_to_text` cho phép người dùng nói và ứng dụng chấm điểm phát âm.
- 📷 **ML Kit Text Recognition:** `google_mlkit_text_recognition` nhận diện chữ Kana/Kanji viết tay từ camera – biến camera thành "vở luyện viết" di động.
- 🔔 **Daily Reminder thông minh:** `flutter_local_notifications` nhắc học lúc **20:00** mỗi ngày với nội dung ngẫu nhiên theo cấp độ.
- 🎭 **Đa nền tảng:** Một codebase chạy mượt trên Android, iOS và Web (Chrome).

---

## 🌸 HỆ THỐNG TÍNH NĂNG CHI TIẾT

### 1. 📇 Flashcards với SRS 🌗

Hệ thống ghi nhớ khoa học – học ít mà nhớ lâu:

- **Vòng đời thẻ:** New → Learning → Review → Mastered (tăng level theo từng câu trả lời đúng).
- **SRS Scheduler:** Tự tính "next review date" dựa trên **Ease Factor** và **interval** chuẩn SuperMemo/SM-2 (xem `lib/services/srs_service.dart`).
- **JLPT filtering:** Lọc nhanh theo cấp độ N5 → N1, hiển thị Kanji, Hiragana, Romaji đồng thời.

### 2. 🤖 AI Practice (Listening • Speaking • Writing) 🎧

Không chỉ học từ vựng – ứng dụng "luyện tứ chi" cho người học:

- **Listening:** Phát âm mẫu bằng `flutter_tts` → người dùng nghe và chọn nghĩa đúng.
- **Speaking:** `speech_to_text` ghi nhận giọng nói → so sánh với câu mẫu → chấm điểm.
- **Writing:** Mở camera, `google_mlkit_text_recognition` nhận diện nét Kanji viết tay → đối chiếu với bảng mẫu.

### 3. 🏆 Bảng Vàng Toàn Cầu (Real-time Leaderboard) 🏅

Cạnh tranh lành mạnh với cộng đồng:

- Dữ liệu `xp, streak, level` được đồng bộ trực tiếp từ Firestore collection `users`.
- Hiển thị **Top 20** nông dân / học viên chăm chỉ nhất server.
- Tự refresh theo stream khi có người chơi lên hạng.

### 4. 🔐 Xác thực đa nền tảng — Email, Google, Facebook 👤

Người dùng đăng nhập cực nhanh:

- `firebase_auth` hỗ trợ **3 phương thức**: Email, Google, Facebook.
- Sau khi đăng nhập, hồ sơ học viên (`xp`, `streak`, `flashcard_progress`) được lưu song song:
  - **Cloud** (Firestore) → đồng bộ giữa mọi thiết bị.
  - **Local** (SQLite) → tiếp tục học kể cả khi offline.

### 5. 📚 Module học theo cấp độ JLPT (N5 → N1) 🎯

Mỗi cấp độ là một "lộ trình" được thiết kế riêng:

- **Từ vựng** theo chủ đề (số, thời gian, gia đình, giao thông…).
- **Kana/Kanji** luyện viết với camera.
- **Mini-test** cuối cấp lưu vào `test_history` để vẽ biểu đồ tiến bộ.

---

## 🎨 GIAO DIỆN (UI/UX)

Giao diện được trau chuốt theo phong cách **Cute Pastel – Glassmorphism** phù hợp với chủ đề Nhật Bản:

- Font chữ **NotoSansJP** được nhúng nguyên bản trong `assets/fonts/` – đảm bảo hiển thị chuẩn mọi ký tự Kanji.
- Hình ảnh & icon đồng bộ tone hồng – trắng – xanh pastel.
- Hiệu ứng Toast Notification trượt nhẹ, Bounce animation khi chuyển tab.
- Audio **BGM** & **SFX** riêng biệt trong `assets/audio/`, phát nhạc nền động lực khi học.
- Hỗ trợ **Dark Mode** (theo theme hệ thống).

---

## 🚀 HƯỚNG DẪN CÀI ĐẶT (Installation)

### Yêu cầu môi trường
- Flutter SDK **>= 3.x**
- Dart **>= 2.18**
- Android Studio / Xcode (tuỳ chọn)
- Chrome (nếu muốn chạy Web)

### Các bước cài đặt

```bash
# 1. Clone source code
git clone https://github.com/<your-username>/NihonGoMaster.git
cd NihonGoMaster

# 2. Cài đặt các gói thư viện Flutter
flutter pub get

# 3. Chạy ứng dụng
# Android:
flutter run
# Hoặc Web (khuyên dùng Chrome):
flutter run -d chrome
# Hoặc iOS:
flutter run -d ios
```

> ⚠️ **Lưu ý:** File `lib/firebase_options.dart` đã được giấu API key thật. App vẫn **chạy được ở chế độ Demo** (offline + dữ liệu mẫu) mà không cần kết nối tới Firebase project thật.

---

## 📸 Hình ảnh Ứng dụng (Screenshots)

| Màn hình Đăng nhập | Flashcards SRS | AI Speaking | Leaderboard | Kana Practice | JLPT Mini-test |
|---|---|---|---|---|---|
| `assets/screenshots/login.png` | `assets/screenshots/flashcards.png` | `assets/screenshots/speaking.png` | `assets/screenshots/leaderboard.png` | `assets/screenshots/kana.png` | `assets/screenshots/minitest.png` |

> *Thư mục `assets/screenshots/` đang được cập nhật – các bạn chạy app sẽ thấy đầy đủ flow thực tế.*

---

## 🏗️ CẤU TRÚC DỰ ÁN (Project Structure)

```
NihonGoMaster/
├── lib/
│   ├── main.dart                      # Entry point + Provider tree
│   ├── constants.dart                 # App constants, JLPT levels, leveling rules
│   ├── models/                        # 11 model classes (User, Vocab, Flashcard…)
│   ├── services/                      # Auth, Firestore, SQLite, TTS, Speech, SRS, Notification
│   ├── screens/                       # 21 màn hình UI (Login, Home, Flashcard, AI Practice…)
│   └── data/                          # Seed data (5 file từ vựng, bài test…)
├── assets/
│   ├── fonts/NotoSansJP/              # Font tiếng Nhật
│   ├── images/                        # Sprite & illustration
│   └── audio/                         # BGM & SFX
├── android/   ios/   web/             # Platform builds
├── pubspec.yaml                       # Khai báo dependencies
└── README.md
```

---

## 🛠️ TECH STACK (Lấy thẳng từ pubspec.yaml)

| Loại | Package |
|---|---|
| State Management | `provider` |
| Backend Cloud | `firebase_core`, `firebase_auth`, `cloud_firestore` |
| Local Database | `sqflite`, `path` |
| Text-to-Speech | `flutter_tts` |
| Speech-to-Text | `speech_to_text` |
| Computer Vision | `google_mlkit_text_recognition` |
| Notification | `flutter_local_notifications`, `timezone` |
| Font tiếng Nhật | `NotoSansJP` |

---

## 📊 QUY MÔ DỰ ÁN

- **~60 file Dart** • **~23.000+ LOC**
- **11 Models** • **10 Services** • **21 Screens** • **5 Data files**
- **Firestore collections:** `users`, `vocabularies`, `flashcard_progress`, `test_history`

---

## 🇻🇳 🇯🇵 🇺🇸 Mô tả ngắn cho CV

**Tiếng Việt:** *Xây dựng ứng dụng học tiếng Nhật đa nền tảng (Flutter + Firebase) với hệ thống Flashcards SRS, luyện phát âm AI, nhận diện Kanji qua camera (ML Kit), và bảng xếp hạng toàn cầu thời gian thực.*

**English:** *Cross-platform Japanese-learning app (Flutter + Firebase) featuring Spaced Repetition flashcards, AI pronunciation practice, ML Kit-based Kanji recognition, and real-time global leaderboard.*

**日本語:** *Flutter と Firebase を用いた多機能日本語学習アプリ。SRS フラッシュカード、AI 発音練習、ML Kit による漢字認識、リアルタイム・ランキング機能を搭載。*

---

## 🤝 ĐÓNG GÓP & LIÊN HỆ

- 👩‍💻 **Developer:** Ngô Thị Minh Phương
- 🎓 **MSSV:** 23012156 — Phenikaa University
- 📧 **Email / GitHub:** xem trên profile repo này

> Nếu bạn thấy dự án hữu ích, hãy ⭐ **star** repo để ủng hộ tác giả nhé! 💖

<p align="center"><em>一緒に日本語をマスターしよう！ 🌸</em></p>
