# GitHub

Đích người dùng yêu cầu: **https://github.com/longngoptit-lab/game_x_o**, public.

GitHub CLI đã cài tại `~/.local/bin/gh` trên máy này. Đăng nhập nếu chưa hoàn tất:

```bash
~/.local/bin/gh auth login --hostname github.com --git-protocol https --web
~/.local/bin/gh auth status
```

Không gửi token/mật khẩu trong chat. Đăng nhập bằng trình duyệt của bạn.

Checkout ban đầu trỏ `WRTeam-in/tic-tac-toe`. Lịch sử cũ có file `android/key.properties`, vì vậy bản public cần lịch sử sạch, không đẩy trực tiếp toàn bộ lịch sử đó. File ký và cấu hình công cụ cá nhân được giữ trên máy, loại khỏi Git. Các cấu hình Firebase hiện tại là placeholder.

Repo public dùng lịch sử mới để không đưa cấu hình ký từ lịch sử cũ lên mạng. Các nhánh gốc vẫn được giữ trong checkout cũ. Clone repo mới để tiếp tục làm việc:

```bash
git clone https://github.com/longngoptit-lab/game_x_o.git
cd game_x_o
bash scripts/setup.sh
```

Giữ ghi nhận nguồn gốc trong README. Không commit keystore, mật khẩu ký, service-account JSON, token hoặc file cấu hình cá nhân. Firebase client config do FlutterFire sinh chứa định danh ứng dụng; quyền truy cập dữ liệu phải được bảo vệ bằng rules/backend.
