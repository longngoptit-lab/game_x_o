# Kiểm tra game_x_o

Ngày kiểm tra: 09–10/11/2026 (Asia/Ho_Chi_Minh).

## Đã đạt

- Cài dependency bằng `flutter pub get`, giữ `pubspec.lock`.
- `flutter analyze`: không có lỗi hoặc cảnh báo.
- `flutter test --coverage`: **54 test đạt**.
- AI hard được đối chiếu với bộ giải độc lập trên hơn 4.000 trạng thái 3×3 hợp lệ, cả khi X đi trước và O đi trước.
- Luật thắng mọi hàng/cột/hai đường chéo của bàn 3×3, 4×4, 5×5; hòa và bàn chưa kết thúc.
- Không đổi lượt khi bấm ô đã có quân hoặc tọa độ không hợp lệ; không nhận lượt mới sau khi kết thúc ván.
- Widget test mở app không Firebase, vào cài đặt, chơi đủ một ván, xem kết quả, chơi lại và về trang chủ.
- Kiểm tra các file chuẩn bị commit không chứa private key, GitHub token hoặc mật khẩu ký Android.

## Lỗi đã sửa trong quá trình kiểm tra

- Ô đã có quân vẫn làm đổi lượt.
- AI trên bàn đầy ép kiểu từ giá trị null.
- AI có thể gửi lượt đi trễ sau khi đóng màn hình.
- Timer marquee vẫn chạy sau dispose; callback nút gọi setState sau dispose.
- Timeout trong chế độ hai người có thể chọn sai người thắng.
- Khởi tạo dịch vụ leaderboard ngay khi mở cài đặt gây lỗi trong chế độ offline.
- Thiếu `await` khi ghi hồ sơ người dùng.
- Thiếu quyền Internet trong Android manifest dùng cho release.

## Build native

- iOS Simulator x86_64: đã build, cài và mở thành công trên iPhone 17 Pro / iOS 26.3. Đã kiểm tra ảnh chụp màn hình trang chủ.
- APK debug Android: đã build thành công; `com.longngoptit.gamexo`, version `2.1.0+17`, min SDK 24, target SDK 36. Đã đọc metadata của APK bằng Android aapt.
- Integration test native trên iPhone 17 Pro / iOS 26.3: **đạt**; tự động mở app, chơi trọn một ván hai người và trở về trang chủ. Đã sửa bước chờ tải màn hình trong test để dùng được với I/O thực của thiết bị.

## Chưa kiểm chứng

Firebase project thật, đăng nhập Google/Apple, multiplayer hai thiết bị, coin/IAP, quảng cáo, upload avatar, release có khóa ký, Google Play/App Store và iPhone thật. Không suy ra những tính năng này đã hoạt động từ kết quả test offline. Đọc [hướng dẫn Firebase](FIREBASE.md) trước khi bật online.
