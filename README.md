# NihonGo Master 🇯🇵

**NihonGo Master** là ứng dụng học tiếng Nhật được phát triển bằng Flutter, tích hợp nhiều nội dung học tập trong một ứng dụng duy nhất như Kana, Kanji, từ vựng, ngữ pháp, đọc hiểu, đề thi thử JLPT và các bài luyện nghe, phát âm, viết có hỗ trợ AI.

Ứng dụng được thiết kế theo hướng **offline-first**, cho phép người dùng tiếp tục học ngay cả khi mất kết nối mạng, đồng thời hỗ trợ đồng bộ dữ liệu thông qua Firebase.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-%3E%3D3.0.0-0175C2?logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%2B%20Firestore-FFCA28?logo=firebase&logoColor=black)
![Platform](https://img.shields.io/badge/Platform-iOS%20%C2%B7%20Android%20%C2%B7%20Web%20%C2%B7%20Desktop-lightgrey)

---

## 🌐 Demo trực tuyến

[![Test trực tiếp](https://img.shields.io/badge/🚀%20Test%20trực%20tiếp-NihonGo%20Master-brightgreen?style=for-the-badge)](https://nihongomasternumber1.netlify.app/)

> **Demo**  
> https://nihongomasternumber1.netlify.app/

---

## 📑 Mục lục

- [Tổng quan](https://github.com/mfuongg/NiHonGoMaster#tổng-quan)
- [Tính năng](https://github.com/mfuongg/NiHonGoMaster#tính-năng)
- [Công nghệ sử dụng](https://github.com/mfuongg/NiHonGoMaster#công-nghệ-sử-dụng)
- [Kiến trúc](https://github.com/mfuongg/NiHonGoMaster#kiến-trúc)
- [Hướng dẫn cài đặt và chạy](https://github.com/mfuongg/NiHonGoMaster#hướng-dẫn-cài-đặt-và-chạy)
- [Cấu trúc dự án](https://github.com/mfuongg/NiHonGoMaster#cấu-trúc-dự-án)
- [Dữ liệu và lưu trữ](https://github.com/mfuongg/NiHonGoMaster#dữ-liệu-và-lưu-trữ)
- [Hạn chế hiện tại](https://github.com/mfuongg/NiHonGoMaster#hạn-chế-hiện-tại)
- [Lộ trình phát triển](https://github.com/mfuongg/NiHonGoMaster#lộ-trình-phát-triển)


---

## Tổng quan

Đối với người Việt học tiếng Nhật, việc học thường phải sử dụng nhiều công cụ riêng biệt: một ứng dụng để học Kana, một website để làm bài JLPT, một ứng dụng flashcard để học từ vựng và một cuốn sổ để ghi chú ngữ pháp.

**NihonGo Master** được xây dựng nhằm đưa các nội dung này vào một ứng dụng duy nhất, giúp người học có thể học tập, luyện tập và theo dõi tiến độ tại cùng một nơi.

Ứng dụng được thiết kế dựa trên ba vấn đề thực tế:

| Vấn đề | Cách dự án giải quyết |
|---|---|
| Người học dễ mất động lực vì các công cụ học tập bị phân tán | Tích hợp Kana → Kanji → Từ vựng → Ngữ pháp → Đọc hiểu → Đề thi thử JLPT |
| Mạng di động không ổn định khiến ứng dụng phụ thuộc hoàn toàn vào cloud dễ bị gián đoạn | Sử dụng kiến trúc offline-first với SQLite cache và dữ liệu được đóng gói sẵn trong ứng dụng |
| Nói và viết là những kỹ năng khó tự đánh giá | Cung cấp các màn hình luyện nghe, phát âm và viết với TTS, nhận dạng giọng nói và OCR |

### 📊 Tổng quan nhanh

| Chỉ số | Giá trị |
|---|---:|
| File Dart trong `lib/` | **60** |
| Tổng số dòng Dart | **~23.900** |
| Dòng Dart không tính nội dung học (`lib/data/`) | **~20.600** |
| Nội dung học trong `lib/data/` | **~3.200 dòng** |
| Số màn hình | **23** |
| Số model dữ liệu | **11** |
| Số provider | **6** |
| Số service | **10** |
| Dependency runtime | **28** |
| Dependency dev | **2** |

---

## Tính năng

### 📖 Nội dung học tập

- **Kana** — luyện Hiragana và Katakana với các màn hình luyện tập theo thứ tự nét viết.
- **Kanji** — tra cứu và học Kanji cùng cách đọc và ý nghĩa.
- **Từ vựng** — tổ chức theo cấp độ JLPT từ N5 đến N1, đi kèm chức năng tìm kiếm.
- **Ngữ pháp** — các điểm ngữ pháp kèm giải thích và câu ví dụ.
- **Đọc hiểu** — tài liệu đọc được phân cấp kèm bài luyện đọc hiểu.
- **Đề thi thử JLPT** — bộ câu hỏi với chấm điểm tự động và xem lại từng câu đúng/sai.

### 🎯 Luyện tập và đánh giá

- **Flashcard** với **spaced repetition** — ưu tiên ôn lại những từ người học trả lời sai.
- **Quiz từ vựng**.
- **Quiz sổ tay từ vựng**.
- **Trò chơi ghép từ**.
- **Luyện nghe** — phát âm thanh và trả lời câu hỏi nghe hiểu.
- **Luyện phát âm** — nhận dạng giọng nói và so sánh với nội dung mục tiêu.
- **Luyện viết** — nhận dạng chữ viết tay thông qua Google ML Kit Text Recognition.
- **Sổ tay từ vựng** — lưu lại những từ khó và luyện lại sau.

### 🏆 Gamification và tạo động lực

- **Hệ thống XP** với phần thưởng cho từng hoạt động.
- **8 cấp độ người dùng** từ *Người mới bắt đầu* đến *Đại sư tiếng Nhật*.
- **Hệ thống thành tích** và phần thưởng XP.
- **Chuỗi ngày học liên tiếp (streak)**.
- **Mục tiêu học tập hằng ngày**.
- **Bảng xếp hạng**.
- **Dashboard tiến độ học tập**.
- **Lịch sử học tập**.
- Animation chuyển cảnh, confetti, shimmer loading và Lottie animation.

### 👤 Tài khoản và tiện ích

- Đăng ký, đăng nhập và đặt lại mật khẩu bằng **Email/Password**.
- **Google Sign-In**.
- **Facebook Login**.
- **Chế độ khách/demo** — có thể chạy ứng dụng mà không cần Firebase thực tế.
- **Light / Dark Theme**.
- **Text-to-Speech tiếng Nhật**.
- **Nhắc học hằng ngày** bằng local notification.
- **Nhạc nền và hiệu ứng âm thanh**.

---

## Công nghệ sử dụng

Các phiên bản dưới đây được lấy từ `pubspec.yaml` của dự án.

### 🧩 Công nghệ cốt lõi

| Package | Phiên bản | Vai trò |
|---|---|---|
| `flutter` | SDK | Framework phát triển giao diện |
| `provider` | `^6.1.1` | Quản lý trạng thái |
| `shared_preferences` | `^2.2.2` | Lưu các thiết lập nhỏ của người dùng |
| `sqflite` | `^2.3.2` | Cơ sở dữ liệu SQLite cục bộ |
| `path` | `^1.9.0` | Xử lý đường dẫn |
| `path_provider` | `^2.1.5` | Truy cập thư mục hệ thống |

### 🔐 Backend và xác thực

| Package | Phiên bản | Vai trò |
|---|---|---|
| `firebase_core` | `^3.13.0` | Khởi tạo Firebase |
| `firebase_auth` | `^5.5.2` | Xác thực tài khoản |
| `cloud_firestore` | `^5.6.6` | Lưu trữ và đồng bộ dữ liệu trên cloud |
| `google_sign_in` | `^6.3.0` | Đăng nhập Google |
| `flutter_facebook_auth` | `^7.1.2` | Đăng nhập Facebook |
| `app_links` | `^7.0.0` | Xử lý deep link cho OAuth |

### 🎤 Âm thanh, nhận dạng và khả năng thiết bị

| Package | Phiên bản | Vai trò |
|---|---|---|
| `flutter_tts` | `^4.2.2` | Text-to-Speech tiếng Nhật |
| `speech_to_text` | `^6.6.2` | Nhận dạng giọng nói |
| `google_mlkit_text_recognition` | `^0.13.0` | Nhận dạng chữ viết |
| `flutter_local_notifications` | `^19.1.0` | Nhắc học hằng ngày |
| `timezone` | `^0.10.1` | Xử lý múi giờ cho notification |
| `audioplayers` | `^6.0.0` | Nhạc nền và hiệu ứng âm thanh |

### 🎨 UI, animation và biểu đồ

| Package | Phiên bản | Vai trò |
|---|---|---|
| `fl_chart` | `^0.68.0` | Biểu đồ tiến độ |
| `percent_indicator` | `^4.2.3` | Vòng/thanh tiến độ |
| `flip_card` | `^0.7.0` | Hiệu ứng lật flashcard |
| `lottie` | `^3.1.0` | Animation |
| `confetti` | `^0.7.0` | Hiệu ứng hoàn thành |
| `animate_do` | `^3.3.4` | Animation UI |
| `flutter_staggered_animations` | `^1.1.1` | Animation danh sách |
| `shimmer` | `^3.0.0` | Loading skeleton |
| `google_fonts` | `^6.2.1` | Font chữ |
| `intl` | `^0.19.0` | Định dạng ngày và số |
| `uuid` | `^4.3.3` | Sinh mã định danh |

### 🛠️ Dependency dành cho phát triển

```text
flutter_test
flutter_lints ^3.0.1
```

---

## Kiến trúc

Codebase sử dụng mô hình phân tách theo phong cách **MVVM nhẹ**, dựa trên `provider`.

```text
UI (screens/ + widgets/)
        │
        │ theo dõi trạng thái
        ▼
Providers (ChangeNotifier)
        │
        ▼
Services
(auth, firestore, sqlite, tts, notification, ai)
        │
        ▼
Models
(các lớp dữ liệu)
```

### Các tầng chính

| Tầng | Trách nhiệm |
|---|---|
| `lib/screens/` | Các màn hình và luồng chức năng |
| `lib/widgets/` | Các thành phần giao diện có thể tái sử dụng |
| `lib/providers/` | Quản lý trạng thái bằng `ChangeNotifier` |
| `lib/services/` | Firebase, Firestore, SQLite, TTS, notification, BGM, AI |
| `lib/models/` | Các lớp dữ liệu |
| `lib/data/` | Dữ liệu học được đóng gói trong mã nguồn |
| `lib/utils/` | Theme và các hằng số dùng chung |

### Hai quyết định kiến trúc đáng chú ý

1. **Firebase là tùy chọn khi chạy ứng dụng.**  
   Ứng dụng có thể chạy ở chế độ demo mà không cần backend Firebase thực tế.

2. **Có cơ chế fallback khi mất mạng.**  
   Dữ liệu được ưu tiên lấy từ Firestore, sau đó fallback về SQLite và cuối cùng là dữ liệu seed được đóng gói trong ứng dụng.

---

## Hướng dẫn cài đặt và chạy

### 📌 Yêu cầu môi trường

- **Flutter SDK** — stable channel.
- **Dart** `>=3.0.0 <4.0.0`.
- **Android Studio** với emulator nếu chạy Android.
- **Xcode** nếu chạy iOS.
- Thiết bị hoặc emulator có **Google Play Services** nếu sử dụng Google ML Kit.

Kiểm tra môi trường:

```bash
flutter --version
flutter doctor
```

---

### 1. Clone repository

```bash
git clone https://github.com/mfuongg/NiHonGoMaster.git
cd NiHonGoMaster
```

---

### 2. Cài đặt package

```bash
flutter pub get
```

---

### 3. Cấu hình Firebase

Ứng dụng có thể chạy ở chế độ **Guest/Demo** mà không cần Firebase thật.

Nếu muốn bật xác thực tài khoản và đồng bộ dữ liệu trên Firebase:

1. Tạo project tại [Firebase Console](https://console.firebase.google.com/).
2. Đăng ký ứng dụng Android/iOS với Firebase.
3. Tải file cấu hình tương ứng.
4. Đối với Android, đặt:

```text
google-services.json
```

vào:

```text
android/app/
```

5. Đối với iOS, đặt:

```text
GoogleService-Info.plist
```

vào:

```text
ios/Runner/
```

6. Mở:

```text
lib/firebase_options.dart
```

và cấu hình Firebase project.

7. Bật các phương thức đăng nhập:

- Email/Password
- Google
- Facebook

8. Tạo các collection Firestore được ứng dụng sử dụng:

```text
users
vocabularies
users/{uid}/flashcard_progress
users/{uid}/test_history
```

---

### 4. Chạy ứng dụng

Trước tiên:

```bash
flutter clean
flutter pub get
```

Sau đó chạy Android:

```bash
flutter run -d android
```

Hoặc chạy trên thiết bị/emulator đã kết nối:

```bash
flutter run
```

---

### 5. Build APK Release

```bash
flutter build apk --release
```

File APK release sẽ được tạo trong thư mục build của Flutter.

> ⚠️ Các plugin mobile như ML Kit, nhận dạng giọng nói và local notification cần thiết bị thật hoặc emulator có Google Play Services. Khi chạy trên trình duyệt web, các chức năng mobile này sẽ không hoạt động đầy đủ.

---

## Cấu trúc dự án

```text
lib/
├── main.dart
├── firebase_options.dart
│
├── data/
│   ├── vocabulary_data.dart
│   ├── kanji_data.dart
│   ├── grammar_data.dart
│   ├── reading_material_data.dart
│   └── jlpt_test_data.dart
│
├── models/
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
│
├── providers/
│   ├── auth_provider.dart
│   ├── vocabulary_provider.dart
│   ├── flashcard_provider.dart
│   ├── progress_provider.dart
│   ├── study_history_provider.dart
│   └── settings_provider.dart
│
├── services/
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
│
├── screens/
│   ├── onboarding/
│   ├── auth/
│   ├── home/
│   ├── vocabulary/
│   ├── kana/
│   ├── kanji/
│   ├── jlpt/
│   ├── grammar/
│   ├── read/
│   ├── dictionary/
│   ├── progress/
│   └── settings/
│
├── widgets/
│   └── community_contribution_section.dart
│
└── utils/
    ├── theme.dart
    └── constants.dart
```

---

## Dữ liệu và lưu trữ

| Nơi lưu trữ | Mục đích |
|---|---|
| **Dữ liệu Dart được đóng gói** (`lib/data/`) | Nội dung học cơ bản gồm từ vựng, Kanji, ngữ pháp, đọc hiểu và câu hỏi JLPT |
| **SQLite** (`sqflite`) | Cache nội dung cục bộ để hỗ trợ sử dụng offline |
| **SharedPreferences** | Lưu streak, XP, level, mục tiêu hằng ngày, dark mode và trạng thái onboarding |
| **Cloud Firestore** | Lưu hồ sơ, tiến độ và lịch sử làm bài, hỗ trợ đồng bộ giữa các thiết bị |

### Luồng đọc dữ liệu

```text
Cloud Firestore
      ↓
SQLite Cache
      ↓
Dữ liệu Seed được đóng gói trong ứng dụng
```

Cách tổ chức này giúp ứng dụng tiếp tục hoạt động ngay cả khi kết nối mạng bị gián đoạn.

---


## Hạn chế hiện tại

Các hạn chế hiện tại của dự án:

- **Chưa có đầy đủ ảnh chụp màn hình** trong repository.
- **Kiểm thử tự động còn hạn chế** và chưa có độ bao phủ đáng kể cho logic học tập.
- **Dữ liệu học tập chưa đầy đủ hoàn toàn cho N5–N1**, hiện ở quy mô phục vụ đồ án.
- **Firebase cần được cấu hình riêng** nếu muốn sử dụng các chức năng xác thực và đồng bộ cloud.
- **Một số tính năng tập trung vào mobile**, đặc biệt là ML Kit, speech recognition và notification.
- Thư mục `assets/data/` không còn được sử dụng; dữ liệu học đã được chuyển sang `lib/data/`.

---

## Lộ trình phát triển

- [ ] Bổ sung unit test cho thuật toán spaced repetition.
- [ ] Bổ sung widget test cho các màn hình quan trọng.
- [ ] Mở rộng dữ liệu từ vựng và Kanji theo JLPT N5–N1.
- [ ] Bổ sung ảnh chụp màn hình vào README.
- [ ] Bổ sung video demo.
- [ ] Hoàn thiện cấu hình Firebase theo hướng dễ triển khai hơn.
- [ ] Thêm GitHub Actions để tự động chạy:

```bash
flutter analyze
flutter test
```

---


## 🔗 Liên kết

### GitHub

https://github.com/mfuongg/NiHonGoMaster

### Demo trực tuyến

https://nihongomasternumber1.netlify.app/

---

## 📊 Thông tin dự án

| Thành phần | Số lượng |
|---|---:|
| File Dart | **60** |
| Dòng code Dart | **~23.900** |
| Màn hình | **23** |
| Model | **11** |
| Provider | **6** |
| Service | **10** |

---

## 🇻🇳 Tóm tắt

**NihonGo Master** là ứng dụng học tiếng Nhật được phát triển bằng Flutter.

Ứng dụng tích hợp:

- Kana
- Kanji
- Từ vựng JLPT
- Ngữ pháp
- Đọc hiểu
- Đề thi thử JLPT
- Flashcard
- Quiz
- Luyện nghe
- Luyện phát âm
- Luyện viết
- Theo dõi tiến độ
- XP và gamification
- Firebase Authentication
- Cloud Firestore
- SQLite offline cache
- AI-assisted practice

Điểm nổi bật của dự án là khả năng **hoạt động theo hướng offline-first**, cho phép người dùng tiếp tục học ngay cả khi không có kết nối mạng ổn định.

---

## ⭐ Nếu bạn thấy dự án hữu ích

Nếu repository này hữu ích hoặc bạn thấy ý tưởng thú vị, hãy **Star ⭐ repository** để ủng hộ dự án.

**Repository:**  
https://github.com/mfuongg/NiHonGoMaster

**Live Demo:**  
https://nihongomasternumber1.netlify.app/
