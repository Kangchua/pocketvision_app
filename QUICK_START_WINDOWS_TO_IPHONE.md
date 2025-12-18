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

### Bước 4: Cài đặt trên iPhone

**Option A: Sideloadly (Dễ nhất)**
1. Download: https://sideloadly.io
2. Kết nối iPhone qua USB
3. Mở Sideloadly
4. Kéo thả folder `Runner.app` vào Sideloadly
5. Nhập Apple ID
6. Click **"Start"**

**Option B: AltStore**
1. Cài AltStore trên iPhone
2. Mở AltStore > My Apps
3. Chọn file `.ipa` hoặc `.app`
4. Install

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

- Xem hướng dẫn đầy đủ: `HUONG_DAN_CHAY_TREN_IPHONE_TU_WINDOWS.md`

---

**Chúc bạn thành công! 🎉**

