# 🚀 Quick Start - Chạy Flutter trên iPhone từ Windows

## ⚠️ Lưu ý quan trọng

**Flutter KHÔNG THỂ build iOS app trực tiếp trên Windows!**

Bạn cần sử dụng một trong các giải pháp sau:

---

## ✅ Giải pháp 1: GitHub Actions (MIỄN PHÍ - Khuyến nghị)

### Bước 1: Tạo GitHub Repository
```bash
cd pocketvision_app
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/username/pocketvision_app.git
git push -u origin main
```

### Bước 2: Chạy Build
1. Vào GitHub repository
2. Click tab **Actions**
3. Chọn workflow **"Build iOS App"**
4. Click **"Run workflow"** > **"Run workflow"**
5. Đợi 5-10 phút để build xong

### Bước 3: Download App
1. Sau khi build xong, click vào workflow run
2. Scroll xuống phần **Artifacts**
3. Download **ios-build**
4. Giải nén file `.zip`
5. Tìm file `Runner.app` trong thư mục giải nén

### Bước 4: Cài đặt trên iPhone

**Option A: Sideloadly (Dễ nhất - Khuyến nghị)**
1. Download: https://sideloadly.io
2. Cài đặt Sideloadly trên Windows
3. Kết nối iPhone qua USB
4. Mở Sideloadly
5. Kéo thả file `Runner.app` vào Sideloadly
6. Nhập Apple ID của bạn
7. Click **"Start"**
8. Đợi cài đặt xong (2-5 phút)
9. Trên iPhone: **Settings > General > VPN & Device Management** > Trust Apple ID của bạn

**Option B: AltStore**
1. Cài AltServer trên Windows: https://altstore.io
2. Cài AltStore trên iPhone
3. Mở AltStore > My Apps > "+"
4. Chọn file `Runner.app`
5. Install

**Option C: 3uTools**
1. Download: https://www.3u.com
2. Kết nối iPhone qua USB
3. Mở 3uTools > Apps > Install
4. Chọn file `Runner.app`

---

## ✅ Giải pháp 2: Codemagic (MIỄN PHÍ - 500 phút/tháng)

1. Đăng ký: https://codemagic.io
2. Connect GitHub repository
3. Chọn iOS platform
4. Click **"Start new build"**
5. Đợi build xong và download `.ipa`

---

## ✅ Giải pháp 3: Thuê Mac Cloud (Trả phí)

- **MacinCloud:** $20-50/tháng
- **MacStadium:** $99/tháng
- **AWS EC2 Mac:** ~$1.08/giờ

Sau khi có Mac:
```bash
cd pocketvision_app
flutter run
```

---

## 🔧 Cấu hình API cho iPhone

File `lib/config/api_config.dart` đã được cấu hình với IP của bạn:
```dart
static const String serverIp = '192.168.100.194';
```

**Đảm bảo:**
- ✅ Backend đang chạy trên Windows
- ✅ iPhone và Windows cùng WiFi
- ✅ Firewall Windows cho phép port 8081

---

## 📱 Test kết nối

Trước khi cài app, test kết nối từ iPhone:

1. Mở Safari trên iPhone
2. Truy cập: `http://192.168.100.194:8081/api/auth/test`
3. Nếu thấy response → Kết nối OK ✅

---

## 🐛 Xử lý lỗi

**"Network request failed"**
→ Kiểm tra: IP đúng? Cùng WiFi? Backend đang chạy?

**"Could not install app"**
→ Trust developer: Settings > General > VPN & Device Management

**"Build failed"**
→ Kiểm tra log trong GitHub Actions

---

## 📚 Tài liệu chi tiết

- Hướng dẫn đầy đủ: `HUONG_DAN_CHAY_TREN_IPHONE_TU_WINDOWS.md`
- Hướng dẫn cài đặt chi tiết: `HUONG_DAN_CAI_DAT_IPHONE.md`

---

## ⚠️ Lưu ý sau khi cài đặt

1. **App hết hạn sau 7 ngày** - Cần cài lại
2. **Trust app:** Settings > General > VPN & Device Management
3. **Đảm bảo backend đang chạy** và cùng WiFi với iPhone
4. **Test kết nối:** Mở Safari trên iPhone, truy cập `http://192.168.100.194:8081/api/auth/test`

---

**Chúc bạn thành công! 🎉**

