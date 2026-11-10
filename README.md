# game_x_o

Game X/O bằng Flutter cho Android và iOS. Mặc định chạy **offline**, không cần đăng nhập, Firebase, quảng cáo hoặc tài khoản thanh toán. Có chơi với AI (3 độ khó) và hai người cùng thiết bị; bàn 3×3, 4×4, 5×5.

## Chạy từ đầu

Môi trường dùng để kiểm tra: Flutter 3.47.9 / Dart 3.13.7, Java 21, Android SDK 36, Xcode 26.2, CocoaPods 1.16.2. Giữ `pubspec.lock` để cài đúng phiên bản thư viện.

```bash
bash scripts/setup.sh
flutter devices
flutter run -d DEVICE_ID
```

Trên macOS có Xcode và iOS Simulator:

```bash
open -a Simulator
flutter run
```

VS Code: mở thư mục dự án, chọn thiết bị ở thanh trạng thái, nhấn F5. Tên Dart package là `game_x_o`; application ID/bundle ID là `com.longngoptit.gamexo`. Thư mục checkout có thể vẫn tên `tic-tac-toe`.

## Build và kiểm tra

```bash
bash scripts/check.sh
flutter build apk --debug
flutter build ios --simulator --debug
flutter test integration_test/offline_smoke_test.dart -d DEVICE_ID
```

APK: `build/app/outputs/flutter-apk/app-debug.apk`.
iOS Simulator: `build/ios/iphonesimulator/Runner.app`.

Bản release Android cần khóa ký của bạn trong `android/key.properties` (không commit). Sau khi cấu hình khóa:

```bash
flutter build appbundle --release
```

iPhone thật cần chọn Apple Development Team của bạn trong Xcode. Bản simulator không cài được lên iPhone thật.

## Firebase và GitHub

- [Thiết lập Firebase riêng và gửi APK qua App Distribution](docs/FIREBASE.md).
- [Cách đăng nhập và đẩy lên GitHub](docs/GITHUB.md).
- [Kết quả kiểm tra và giới hạn hiện tại](docs/VALIDATION.md).

Cấu hình Android/iOS đã gắn vào Firebase project **`game-x-o-71dd5`** của bạn. [Bản APK trên App Distribution](https://console.firebase.google.com/project/game-x-o-71dd5/appdistribution/app/android:com.longngoptit.gamexo/releases/1hnbg5a5ffu40). Mặc định vẫn chơi offline. Để bật đăng nhập/dữ liệu online, cần khởi tạo Authentication và Realtime Database như trong hướng dẫn Firebase.

Để chuyển project hoặc lấy lại cấu hình sau khi tạo database:

```bash
bash scripts/configure_firebase.sh YOUR_PROJECT_ID
flutter run --dart-define=OFFLINE_MODE=false
```

Phần online kế thừa từ [WRTeam-in/tic-tac-toe](https://github.com/WRTeam-in/tic-tac-toe); cần hoàn tất cấu hình và kiểm thử backend trước khi phát hành. Không có bản web trong checkout này.

Upload bản chơi thử tiếp theo lên Firebase:

```bash
bash scripts/distribute_android.sh
```
