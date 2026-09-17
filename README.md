# NihonGo Master 🇯🇵

**Ứng dụng học tiếng Nhật toàn diện được phát triển bằng Flutter** — cung cấp các nội dung học Kana, Kanji, từ vựng, ngữ pháp, đọc hiểu, đề thi thử JLPT và các bài luyện nói / phát âm / viết có hỗ trợ AI, với kiến trúc ưu tiên hoạt động ngoại tuyến và đồng bộ Firebase.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-%3E%3D3.0.0-0175C2?logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%2B%20Firestore-FFCA28?logo=firebase&logoColor=black)
![Platform](https://img.shields.io/badge/Platform-iOS%20%C2%B7%20Android%20%C2%B7%20Web%20%C2%B7%20Desktop-lightgrey)

## 🌐 Demo trực tuyến

[![Test trực tiếp](https://img.shields.io/badge/🚀%20Test%20trực%20tiếp-NihonGo%20Master-brightgreen?style=for-the-badge)](https://nihongomasternumber1.netlify.app/)

> 🔗 **Link test trực tiếp:** https://nihongomasternumber1.netlify.app/

---

## 📑 Mục lục

- [Tổng quan](#tổng-quan)
- [Tính năng](#tính-năng)
- [Công nghệ sử dụng](#công-nghệ-sử-dụng)
- [Kiến trúc](#kiến-trúc)
- [Hướng dẫn cài đặt và chạy](#hướng-dẫn-cài-đặt-và-chạy)
- [Cấu trúc dự án](#cấu-trúc-dự-án)
- [Dữ liệu và lưu trữ](#dữ-liệu-và-lưu-trữ)
- [Ảnh chụp màn hình](#ảnh-chụp-màn-hình)
- [Hạn chế hiện tại](#hạn-chế-hiện-tại)
- [Lộ trình phát triển](#lộ-trình-phát-triển)
- [Tóm tắt dự án bằng tiếng Việt](#tóm-tắt-dự-án-bằng-tiếng-việt)

---

## Tổng quan

Đối với người Việt học tiếng Nhật, việc học thường phải sử dụng nhiều công cụ riêng biệt: một ứng dụng cho Kana, một website để làm bài JLPT, một ứng dụng flashcard cho từ vựng và một cuốn sổ để học ngữ pháp. **NihonGo Master tích hợp tất cả những nội dung này vào một ứng dụng duy nhất** và vẫn có thể tiếp tục hoạt động khi kết nối mạng bị gián đoạn.

Ứng dụng được xây dựng dựa trên ba vấn đề thực tế:

| Vấn đề | Cách dự án giải quyết |
|---|---|
| Người học dễ mất động lực vì các công cụ học tập bị phân tán | Tích hợp Kana → Kanji → từ vựng → ngữ pháp → đọc hiểu → đề thi thử JLPT trong một ứng dụng |
| Mạng di động không ổn định khiến ứng dụng phụ thuộc hoàn toàn vào cloud dễ bị gián đoạn | Kiến trúc offline-first: cache SQLite + dữ liệu có sẵn trong ứng dụng, Firestore chỉ đóng vai trò đồng bộ nâng cao |
| Nói và viết là những kỹ năng khó tự đánh giá | Các màn hình luyện nghe, phát âm và viết có hỗ trợ AI, sử dụng TTS + nhận dạng giọng nói + OCR trên thiết bị |

### Tổng quan nhanh

| Chỉ số | Giá trị |
|---|---|
| Số file Dart trong `lib/` | **60** |
| Tổng số dòng Dart | **~23.900** |
| Số dòng Dart không tính nội dung học (`lib/data/`) | **~20.600** |
| Nội dung học trong `lib/data/` | **~3.200 dòng** |
| Số màn hình | **23** |
| Số model dữ liệu | **11** |
| Số provider quản lý trạng thái | **6** |
| Số service | **10** |
| Số dependency được khai báo | **28** runtime + 2 dev |

---

## Tính năng

### 📖 Nội dung học tập

- **Kana** — luyện Hiragana và Katakana với các màn hình luyện tập theo thứ tự nét viết
- **Kanji** — tra cứu và học Kanji cùng cách đọc và ý nghĩa
- **Từ vựng** — được tổ chức theo cấp độ JLPT (N5 → N1), đi kèm màn hình từ điển có tìm kiếm
- **Ngữ pháp** — các điểm ngữ pháp kèm giải thích và câu ví dụ
- **Đọc hiểu** — tài liệu đọc được phân cấp kèm bài luyện đọc hiểu
- **Đề thi thử JLPT** — bộ câu hỏi đầy đủ, chấm điểm tự động và xem lại từng câu đúng / sai

### 🎯 Luyện tập và đánh giá

- **Flashcard** với **spaced repetition** — giao diện lật thẻ và thuật toán tự động ưu tiên ôn lại những từ trả lời sai
- **Quiz từ vựng**, **quiz sổ tay** và **trò chơi ghép từ**
- **Luyện nghe** — phát âm thanh và trả lời câu hỏi kiểm tra khả năng nghe hiểu
- **Luyện phát âm** — sử dụng nhận dạng giọng nói để so sánh cách phát âm của người học với từ mục tiêu
- **Luyện viết** — nhận dạng chữ viết tay ngay trên thiết bị thông qua Google ML Kit Text Recognition
- **Sổ tay từ vựng** — lưu lại những từ khó và luyện lại sau

### 🏆 Tạo động lực và gamification

- **Hệ thống XP** với phần thưởng cho từng hoạt động như học từ mới, vượt qua quiz hoặc duy trì streak
- **8 cấp độ người dùng** từ *Người mới bắt đầu* đến *Đại sư tiếng Nhật*, mỗi cấp độ có biểu tượng riêng
- **Thành tích** được mở khóa theo các mốc tiến độ và nhận thêm XP
- **Chuỗi ngày học liên tiếp** và thiết lập mục tiêu học mỗi ngày
- **Bảng xếp hạng** để so sánh tiến độ học tập
- **Dashboard tiến độ** với biểu đồ và lịch sử học tập đầy đủ
- Lớp hoàn thiện giao diện với animation chuyển cảnh, confetti khi hoàn thành, shimmer loading và Lottie animation

### 👤 Tài khoản và khả năng hỗ trợ người dùng

- Đăng ký, đăng nhập và đặt lại mật khẩu bằng **email/password**
- **Google Sign-In** và **Facebook Login** thông qua `google_sign_in` và `flutter_facebook_auth`
- **Chế độ khách/demo** — ứng dụng có thể chạy và trình diễn mà không cần Firebase thực tế
- Chuyển đổi **Light / Dark theme**, được lưu lại giữa các lần chạy
- **Text-to-Speech tiếng Nhật** cho từ vựng và câu ví dụ
- **Nhắc học mỗi ngày** bằng local notification, mặc định vào 20:00
- Nhạc nền và hiệu ứng âm thanh cho các trạng thái đúng / sai / bỏ qua / hoàn thành

---

## Công nghệ sử dụng

Các phiên bản dưới đây được lấy trực tiếp từ `pubspec.yaml` của dự án.

### Công nghệ cốt lõi

| Package | Phiên bản | Vai trò |
|---|---|---|
| `flutter` | SDK | Framework giao diện cho iOS / Android / Web / Desktop |
| `provider` | `^6.1.1` | Quản lý trạng thái |
| `shared_preferences` | `^2.2.2` | Lưu các thiết lập nhỏ như theme, streak, XP và mục tiêu hằng ngày |
| `sqflite` | `^2.3.2` | Cơ sở dữ liệu SQLite cục bộ cho dữ liệu offline |
| `path` / `path_provider` | `^1.9.0` / `^2.1.5` | Xử lý đường dẫn file cho cơ sở dữ liệu cục bộ |

### Backend và xác thực

| Package | Phiên bản | Vai trò |
|---|---|---|
| `firebase_core` | `^3.13.0` | Khởi tạo Firebase |
| `firebase_auth` | `^5.5.2` | Xác thực tài khoản |
| `cloud_firestore` | `^5.6.6` | Đồng bộ tiến độ người dùng và nội dung dùng chung trên cloud |
| `google_sign_in` | `^6.3.0` | Đăng nhập bằng Google |
| `flutter_facebook_auth` | `^7.1.2` | Đăng nhập bằng Facebook |
| `app_links` | `^7.0.0` | Xử lý deep link cho luồng chuyển hướng OAuth |

### Nhập, xuất và khả năng của thiết bị

| Package | Phiên bản | Vai trò |
|---|---|---|
| `flutter_tts` | `^4.2.2` | Chuyển văn bản tiếng Nhật thành giọng nói |
| `speech_to_text` | `^6.6.2` | Kiểm tra phát âm bằng nhận dạng giọng nói |
| `google_mlkit_text_recognition` | `^0.13.0` | Nhận dạng ký tự trên thiết bị cho chức năng luyện viết |
| `flutter_local_notifications` + `timezone` | `^19.1.0` + `^0.10.1` | Đặt lịch nhắc học hằng ngày |
| `audioplayers` | `^6.0.0` | Phát nhạc nền và hiệu ứng âm thanh |

### Giao diện, animation và biểu đồ

| Package | Phiên bản | Vai trò |
|---|---|---|
| `fl_chart` | `^0.68.0` | Biểu đồ tiến độ |
| `percent_indicator` | `^4.2.1` | Vòng tròn / thanh tiến độ |
| `flip_card` | `^0.7.0` | Animation lật flashcard |
| `lottie` | `^3.1.0` | Animation vector |
| `confetti` | `^0.7.0` | Hiệu ứng chúc mừng |
| `animate_do` | `^3.3.4` | Animation xuất hiện |
| `flutter_staggered_animations` | `^1.1.1` | Animation danh sách |
| `shimmer` | `^3.0.0` | Skeleton loading |
| `google_fonts` | `^6.2.1` | Font chữ |
| `intl` | `^0.19.0` | Định dạng ngày và số |
| `uuid` | `^4.3.3` | Sinh mã định danh |

**Dependency dành cho phát triển:** `flutter_test`, `flutter_lints ^3.0.1`

---

## Kiến trúc

Codebase sử dụng mô hình phân tách theo phong cách **MVVM nhẹ**, dựa trên `provider`:

```text
UI (screens/ + widgets/)  ──theo dõi──▶  Providers (ChangeNotifier)
                                              │
                                              ▼
                                      Services (auth, firestore,
                                      sqlite, tts, notification, ai)
                                              │
                                              ▼
                                      Models (các lớp dữ liệu)
