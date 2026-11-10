# Firebase của bạn

## Trạng thái đã thiết lập

- Project đang dùng: **`game-x-o-71dd5`** ([mở Console](https://console.firebase.google.com/project/game-x-o-71dd5/overview)).
- Đã đăng ký Android và iOS với ID `com.longngoptit.gamexo`, sinh đầy đủ cấu hình Flutter/native.
- Đã upload APK **2.1.0 (17)** lên [App Distribution](https://console.firebase.google.com/project/game-x-o-71dd5/appdistribution/app/android:com.longngoptit.gamexo/releases/1hnbg5a5ffu40).
- Bản APK mặc định chơi offline. Authentication và Realtime Database chưa khởi tạo tại thời điểm kiểm tra cuối. Để dùng online: bấm **Get started** trong Authentication; tạo Realtime Database tại **Hoa Kỳ** theo lựa chọn của bạn, chọn **Locked mode**, rồi chạy lại `bash scripts/configure_firebase.sh game-x-o-71dd5` để lấy Database URL. Sau đó hoàn tất providers và rules theo các mục bên dưới.

Upload bản offline tiếp theo bằng `bash scripts/distribute_android.sh`. Script đọc Project ID và App ID từ cấu hình native, build APK rồi upload. Việc thêm tester được thực hiện trong Firebase Console.

## Cách nhanh nhất: gửi APK chạy offline

Firebase App Distribution cho phép tải APK lên để cài thử. Không cần chuyển game sang online, không cần mua domain hay Firebase Hosting.

1. Mở [Firebase Console](https://console.firebase.google.com/), đăng nhập Google của bạn, chọn **Create a project**, đặt tên `game-x-o`. Có thể bỏ qua Google Analytics.
2. Trong Project settings, thêm ứng dụng Android với package **`com.longngoptit.gamexo`**. Ghi lại **App ID** dạng `1:…:android:…` và **Project ID**.
3. Mở **App Distribution → Get started** và tải `build/app/outputs/flutter-apk/app-debug.apk` lên. Thêm email người thử nếu muốn gửi lời mời.
4. Người thử mở lời mời trên Android và cài bản APK. Bản này chơi offline được ngay.

Cách tương đương bằng terminal, sau khi tạo app:

```bash
firebase login
flutter build apk --debug
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-debug.apk \
  --project YOUR_PROJECT_ID \
  --app YOUR_ANDROID_FIREBASE_APP_ID \
  --release-notes 'game_x_o — offline preview'
```

APK 2.1.0 (17) đã được upload vào project `game-x-o-71dd5`. Firebase CLI và FlutterFire CLI đã được cài và đăng nhập trên máy. Tham khảo [hướng dẫn App Distribution chính thức](https://firebase.google.com/docs/app-distribution/android/distribute-cli).

## Kết nối tính năng online với project riêng

1. Trong **Authentication → Sign-in method**, bật Anonymous và Email/Password. Bật Google nếu cần đăng nhập Google; Apple cần cấu hình Apple Developer riêng.
2. Tạo **Realtime Database** (ứng dụng này không dùng Firestore). Chọn vùng gần người chơi và bắt đầu với rules khóa quyền. Ghi lại Database URL.
3. Chạy cấu hình:

```bash
bash scripts/configure_firebase.sh YOUR_PROJECT_ID
```

Script đăng nhập Google, đăng ký app Android/iOS, sinh `lib/firebase_options.dart`, cấu hình native và cập nhật URL scheme Google trên iOS nếu provider đã bật. Quy trình dựa trên [FlutterFire setup](https://firebase.google.com/docs/flutter/setup). Nếu bật thêm Google hoặc tạo Realtime Database sau đó, chạy lại script để lấy cấu hình mới.

4. Với Google Sign-In trên Android, lấy SHA-1/SHA-256 từ `cd android && ./gradlew signingReport`, thêm vào Android app trong Firebase Console rồi chạy lại script. Release dùng fingerprint của khóa ký release / Play App Signing.
5. Với App Check, bản debug dùng debug provider. Đăng ký debug token được in trong log vào **App Check → Manage debug tokens** nếu đã bật enforcement. Bản phát hành dùng Play Integrity / App Attest.
6. Chạy app kết nối:

```bash
flutter run --dart-define=OFFLINE_MODE=false
```

Các nút online hiện lại khi tắt offline mode. Chỉ chạy bước này sau khi cấu hình xong Authentication, Database URL và rules. Checkout hiện tại đã trỏ project `game-x-o-71dd5`.

## Quyền dữ liệu và phần chưa được xác minh

Code gốc có `users`, `userSkins`, `games`, `history`, `availableSkins`, `shopItems`. Chưa có bộ Security Rules hoặc backend tin cậy trong dự án gốc. Quyền tối thiểu cho đăng nhập: người chơi đọc/ghi hồ sơ và skin của chính họ; catalog chỉ đọc; leaderboard cần đọc profile công khai và index `score`, `rankKey`; tìm trận cần index `time_created`.

**Không mở toàn bộ database để làm multiplayer chạy.** Cơ chế gốc thanh toán coin, ghi điểm và lịch sử của cả hai người từ một client. Rules chỉ cho ghi dữ liệu chính mình sẽ chặn phần thanh toán này; cho mọi tài khoản ghi chéo lại cho phép gian lận. Trước khi phát hành online, cần chuyển xác minh lượt đi/kết quả, thanh toán coin và xác minh giao dịch mua sang backend, rồi kiểm thử rules và hai thiết bị. Phần này chưa được triển khai hoặc xác nhận chạy trên project của bạn. Xem [Firebase: tránh rules không an toàn](https://firebase.google.com/docs/rules/insecure-rules).

Upload ảnh đại diện cần Cloud Storage. Firebase hiện yêu cầu gói Blaze để dùng Cloud Storage; chỉ bật nếu bạn muốn dùng tính năng này và tự thiết lập billing. Chơi offline và gửi APK không cần cấu hình upload avatar. [Yêu cầu Cloud Storage](https://firebase.google.com/docs/storage/flutter/start).

## Phân biệt các hình thức phát hành

- **App Distribution:** chia sẻ bản cài thử Android/iOS. iOS cần ký đúng provisioning profile và thiết bị thử.
- **Google Play / App Store:** phát hành ứng dụng; cần tài khoản developer và khóa ký của bạn.
- **Firebase Hosting:** dành cho web. Dự án hiện có plugin mobile, chưa hỗ trợ build web; không dùng `firebase deploy --only hosting` cho APK.
