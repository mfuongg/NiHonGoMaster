# NihonGo Master

Ứng dụng học tiếng Nhật bằng Flutter cho bài tập lớn môn Lập trình cho thiết bị di động.

## Các tính năng đã bổ sung

- Đăng nhập / Đăng ký / Quên mật khẩu
- Đăng nhập Google, Facebook
- Kiến trúc theo hướng MVVM-lite với `Provider` + `Service`
- Đồng bộ Firebase Authentication / Firestore (khi cấu hình Firebase thật)
- Chế độ fallback offline/demo nếu chưa cấu hình Firebase
- Flashcard lật thẻ với thuật toán **Spaced Repetition**
- Chấm điểm bài test, hiển thị số câu đúng/sai, lưu lịch sử học tập
- Cache dữ liệu từ vựng offline bằng **SQLite (sqflite)**
- TTS phát âm tiếng Nhật bằng `flutter_tts`
- Local notification nhắc học mỗi ngày lúc **20:00**
- Cơ chế gọi dữ liệu từ Firestore, fallback về local cache/hard seed khi offline

## Cấu trúc chính

```text
lib/
  models/
  providers/
  services/
  screens/
    auth/
    vocabulary/
    jlpt/
    progress/
```

## Cấu hình Firebase

Dự án hiện được viết theo hướng **compile được ngay cả khi chưa có Firebase thật**, để bạn dễ demo offline.

Muốn bật Firebase thật:

1. Mở `lib/firebase_options.dart`
2. Đặt `configured = true`
3. Điền các thông số Firebase của bạn
4. (Khuyến nghị) thêm `google-services.json` vào `android/app/`
5. Bật Email/Password, Google, Facebook trong Firebase Console
6. Tạo Firestore collections:
   - `users`
   - `vocabularies`
   - `users/{uid}/flashcard_progress`
   - `users/{uid}/test_history`

## Chạy dự án

```bash
flutter clean
flutter pub get
flutter run -d android
```

> Nếu bạn build trên Chrome nhưng project chưa cấu hình web thì sẽ lỗi. Với bài tập lớn mobile, hãy chạy Android emulator hoặc điện thoại Android.

## Gợi ý demo với giảng viên

- Đăng ký tài khoản mới
- Đăng nhập Google/Facebook
- Mở Flashcard, lật thẻ, bấm phát âm tiếng Nhật
- Làm 1 đề JLPT, cho xem đúng/sai + lịch sử học tập
- Tắt mạng và chứng minh vẫn xem được từ vựng đã cache từ SQLite
- Mở phần Cài đặt và cho xem notification 20:00
