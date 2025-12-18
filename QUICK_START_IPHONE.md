# 🚀 Quick Start - Chạy trên iPhone

## ⚡ 3 Bước nhanh

### 1️⃣ Lấy IP máy tính
```bash
# Mac:
ifconfig | grep "inet " | grep -v 127.0.0.1

# Windows:
ipconfig
```
**Ghi nhớ IP** (ví dụ: `192.168.1.100`)

### 2️⃣ Cập nhật IP trong code
Mở file: `lib/config/api_config.dart`

Thay đổi dòng:
```dart
static const String serverIp = 'localhost';  // ❌ Xóa
static const String serverIp = '192.168.1.100';  // ✅ Thay bằng IP của bạn
```

### 3️⃣ Chạy app
```bash
cd pocketvision_app
flutter run
```

Chọn iPhone từ danh sách devices.

---

## ✅ Checklist

- [ ] Mac với Xcode đã cài
- [ ] iPhone kết nối USB với Mac
- [ ] Đã trust developer trên iPhone (Settings > General > VPN & Device Management)
- [ ] Backend đang chạy (`./mvnw spring-boot:run`)
- [ ] iPhone và Mac cùng WiFi
- [ ] Đã cập nhật IP trong `api_config.dart`

---

## 🔧 Xử lý lỗi

**"Network request failed"**
→ Kiểm tra: IP đúng chưa? Cùng WiFi? Backend đang chạy?

**"Signing requires a development team"**
→ Mở Xcode > Runner > Signing & Capabilities > Chọn Team

**"Could not find Developer Disk Image"**
→ Cập nhật Xcode: `xcode-select --install`

---

📖 Xem hướng dẫn chi tiết: `HUONG_DAN_CHAY_TREN_IPHONE.md`




