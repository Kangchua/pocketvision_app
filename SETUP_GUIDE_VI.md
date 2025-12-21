# PocketVision Flutter App - Setup Guide

## Ứng Dụng Quản Lý Tài Chính Cho Di Động

Ứng dụng Flutter mới cho PocketVision với các tính năng quản lý chi tiêu, ngân sách và tài chính cá nhân.

## 📋 Yêu Cầu

- Flutter SDK >= 3.10.4
- Dart >= 3.10.4
- Android Studio hoặc Xcode
- Backend API chạy trên `http://localhost:8080` (hoặc cấu hình lại)

## 🚀 Hướng Dẫn Cài Đặt Nhanh

### 1. Cài Đặt Dependencies

```bash
cd pocketvision_app
flutter pub get
```

### 2. Cấu Hình API

Chỉnh sửa file `lib/services/api_service.dart`:

```dart
static const String baseUrl = 'http://localhost:8080/api';
// Thay đổi thành địa chỉ server của bạn nếu khác
```

### 3. Chạy Ứng Dụng

**Android:**
```bash
flutter run
```

**iOS:**
```bash
flutter run -d ios
```

**Web:**
```bash
flutter run -d chrome
```

## 📱 Các Tính Năng

✅ **Xác thực người dùng**
- Đăng nhập
- Đăng ký tài khoản mới

✅ **Quản lý chi tiêu**
- Xem danh sách chi tiêu
- Thêm chi tiêu mới
- Chỉnh sửa chi tiêu
- Xóa chi tiêu
- Phân loại theo danh mục

✅ **Quản lý ngân sách**
- Xem ngân sách
- Theo dõi chi tiêu vs ngân sách
- Hiển thị tiến độ bằng thanh tiến trình

✅ **Dashboard**
- Thống kê tổng chi tiêu
- Thông tin người dùng
- Nút hành động nhanh

✅ **Hồ sơ người dùng**
- Xem thông tin cá nhân
- Cài đặt
- Đăng xuất

## 🏗️ Cấu Trúc Dự Án

```
lib/
├── models/                 # Các lớp dữ liệu
├── services/              # Dịch vụ API
├── providers/             # Quản lý trạng thái (Provider)
├── screens/               # Các màn hình UI
├── widgets/               # Widget tái sử dụng
├── utils/                 # Các hàm tiện ích
└── main.dart             # Điểm vào ứng dụng
```

## 🎨 Tính Năng Giao Diện

- 🎨 Thiết kế Material 3
- 🌐 Hỗ trợ tiếng Việt
- 📱 Bố cục đáp ứng
- ⚡ Hoạt ảnh mượt mà
- 🔄 Chức năng làm tươi

## 📦 Dependencies Chính

```yaml
provider: ^6.4.0              # Quản lý trạng thái
dio: ^5.4.0                   # HTTP client
shared_preferences: ^2.2.2    # Lưu trữ cục bộ
intl: ^0.19.0                 # Quốc tế hóa
fl_chart: ^0.65.0             # Biểu đồ
image_picker: ^1.0.8          # Chọn ảnh
```

## 🔗 API Endpoints

### Xác thực
```
POST /api/auth/register          # Đăng ký
POST /api/auth/login             # Đăng nhập
```

### Chi tiêu
```
GET /api/expenses?userId={id}    # Lấy danh sách
POST /api/expenses               # Thêm mới
PUT /api/expenses/{id}           # Cập nhật
DELETE /api/expenses/{id}        # Xóa
```

### Danh mục
```
GET /api/categories?userId={id}  # Lấy danh sách
POST /api/categories             # Thêm mới
```

### Ngân sách
```
GET /api/budgets?userId={id}     # Lấy danh sách
POST /api/budgets                # Thêm mới
```

## 🛠️ Các Lệnh Hữu Ích

```bash
# Kiểm tra cấu hình
flutter doctor

# Cài đặt dependencies
flutter pub get

# Làm sạch bộ nhớ cache
flutter clean

# Build APK Release
flutter build apk --release

# Build APK Debug
flutter build apk --debug

# Chạy trên thiết bị cụ thể
flutter devices
flutter run -d <device_id>

# Hot reload (thay đổi nhanh)
flutter run
# Sau đó nhấn 'r' trong terminal
```

## 🔍 Khắc Phục Lỗi

### Ứng dụng không kết nối được API
1. Kiểm tra server backend đang chạy
2. Xác minh địa chỉ API trong `api_service.dart`
3. Kiểm tra kết nối mạng của thiết bị

### Lỗi Flutter
```bash
flutter clean
flutter pub get
flutter run
```

### Lỗi Build Android
```bash
# Cập nhật Gradle
./gradlew wrapper --gradle-version=<version>
```

## 📊 Tính Năng Sắp Tới

- 📈 Phân tích chi tiêu nâng cao
- 📧 Báo cáo hàng tháng
- 📸 Tải lên hóa đơn
- 🤖 Gợi ý chi tiêu AI
- 🔔 Cảnh báo ngân sách
- 💾 Xuất dữ liệu (PDF, CSV)

## 📝 Ghi Chú

- Ứng dụng sử dụng `Provider` để quản lý trạng thái
- Dữ liệu người dùng được lưu trữ trong `SharedPreferences`
- Hỗ trợ định dạng tiếng Việt cho ngày tháng và tiền tệ
- API base URL có thể được cấu hình trong `lib/services/api_service.dart`

## 📞 Hỗ Trợ

Nếu gặp vấn đề, vui lòng:
1. Kiểm tra `flutter doctor` output
2. Xóa cache với `flutter clean`
3. Cài đặt lại dependencies

---

**Phiên bản:** 1.0.0  
**Ngôn ngữ:** Dart + Flutter  
**Cập nhật lần cuối:** Tháng 12 năm 2025
