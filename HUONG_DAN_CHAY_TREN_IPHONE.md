# Hướng dẫn chạy ứng dụng Flutter trên iPhone

## Yêu cầu trước khi bắt đầu

1. **Mac với Xcode** (bắt buộc - không thể build iOS app trên Windows/Linux)
2. **iPhone** kết nối với Mac qua cáp USB
3. **Apple Developer Account** (miễn phí hoặc có phí)
4. **Flutter SDK** đã được cài đặt
5. **Backend server** đang chạy trên máy tính

## Bước 1: Lấy IP của máy tính

Ứng dụng cần kết nối đến backend server. Bạn cần biết IP của máy tính chạy backend.

### Trên Mac:
```bash
# Mở Terminal và chạy:
ifconfig | grep "inet " | grep -v 127.0.0.1
```

Hoặc vào **System Preferences > Network** để xem IP (thường là 192.168.x.x)

### Trên Windows:
```powershell
# Mở PowerShell và chạy:
ipconfig
```

Tìm **IPv4 Address** (thường là 192.168.x.x)

### Ví dụ:
Nếu IP của máy bạn là `192.168.1.100` và backend chạy trên port `8081`, URL sẽ là:
```
http://192.168.1.100:8081/api
```

## Bước 2: Cập nhật Base URL trong code

Mở file `lib/services/api_service.dart` và thay đổi:

```dart
// Thay đổi từ:
static const String baseUrl = 'http://localhost:8081/api';

// Thành IP của máy bạn (ví dụ):
static const String baseUrl = 'http://192.168.1.100:8081/api';
```

**Lưu ý:** Đảm bảo iPhone và máy tính đang cùng một mạng WiFi!

## Bước 3: Cấu hình Xcode

1. **Mở project trong Xcode:**
   ```bash
   cd pocketvision_app
   open ios/Runner.xcworkspace
   ```

2. **Chọn Team (Signing & Capabilities):**
   - Chọn **Runner** trong Project Navigator (bên trái)
   - Chọn tab **Signing & Capabilities**
   - Chọn **Team** của bạn (nếu chưa có, chọn "Add Account" và đăng nhập Apple ID)
   - Xcode sẽ tự động tạo Bundle Identifier

3. **Chọn iPhone làm target:**
   - Ở thanh toolbar phía trên, chọn iPhone của bạn từ dropdown (thay vì Simulator)
   - Nếu iPhone chưa hiện, kết nối iPhone qua USB và trust máy tính

## Bước 4: Trust Developer trên iPhone

Lần đầu chạy app trên iPhone:

1. Kết nối iPhone với Mac qua USB
2. Trên iPhone, vào **Settings > General > VPN & Device Management**
3. Tìm tên Apple ID của bạn và tap **Trust**
4. Xác nhận **Trust**

## Bước 5: Chạy ứng dụng

### Cách 1: Từ Xcode
1. Chọn iPhone làm target
2. Nhấn nút **Play** (▶️) hoặc `Cmd + R`

### Cách 2: Từ Terminal/Command Line
```bash
cd pocketvision_app
flutter run -d <device-id>
```

Để xem danh sách devices:
```bash
flutter devices
```

## Bước 6: Kiểm tra kết nối

1. **Đảm bảo backend đang chạy:**
   ```bash
   # Trong thư mục backend
   cd PBL6-vision-money/back/ledger
   ./mvnw spring-boot:run
   ```

2. **Kiểm tra firewall:**
   - Trên Mac: System Preferences > Security & Privacy > Firewall
   - Đảm bảo cho phép kết nối đến port 8081

3. **Test kết nối từ iPhone:**
   - Mở Safari trên iPhone
   - Truy cập: `http://192.168.1.100:8081/api/auth/test`
   - Nếu thấy response, kết nối OK!

## Xử lý lỗi thường gặp

### Lỗi: "Could not find Developer Disk Image"
- **Giải pháp:** Cập nhật Xcode lên phiên bản mới nhất

### Lỗi: "Signing for Runner requires a development team"
- **Giải pháp:** Chọn Team trong Xcode > Signing & Capabilities

### Lỗi: "Unable to boot the Simulator"
- **Giải pháp:** Chạy `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`

### Lỗi: "Network request failed" hoặc không kết nối được backend
- **Kiểm tra:**
  1. iPhone và máy tính có cùng WiFi không?
  2. IP address đã đúng chưa?
  3. Backend có đang chạy không?
  4. Firewall có chặn port 8081 không?

### Lỗi: "App installation failed"
- **Giải pháp:**
  1. Xóa app cũ trên iPhone (nếu có)
  2. Clean build: `flutter clean`
  3. Chạy lại: `flutter run`

## Tối ưu hóa: Tự động detect IP

Để tránh phải thay đổi IP mỗi lần, bạn có thể tạo một file config:

**Tạo file `lib/config/api_config.dart`:**
```dart
class ApiConfig {
  // Thay đổi IP này theo IP của máy bạn
  static const String serverIp = '192.168.1.100';
  static const int serverPort = 8081;
  static const String baseUrl = 'http://$serverIp:$serverPort/api';
}
```

Sau đó import trong `api_service.dart`:
```dart
import '../config/api_config.dart';

class ApiService {
  static const String baseUrl = ApiConfig.baseUrl;
  // ...
}
```

## Lưu ý quan trọng

1. **HTTP vs HTTPS:**
   - iOS mặc định chỉ cho phép HTTPS
   - Đã cấu hình `NSAllowsArbitraryLoads` trong Info.plist để cho phép HTTP (chỉ dùng cho development)
   - **Production:** Nên dùng HTTPS với SSL certificate

2. **Network Security:**
   - Đảm bảo iPhone và máy tính cùng mạng WiFi
   - Không dùng mạng công cộng (có thể bị chặn)

3. **Hot Reload:**
   - Khi chạy trên device thật, vẫn có thể dùng Hot Reload (`r` trong terminal)
   - Hot Restart: `R` (chữ hoa)

## Bước tiếp theo

Sau khi chạy thành công:
- Test các chức năng: đăng nhập, tạo chi tiêu, xem báo cáo...
- Kiểm tra performance trên device thật
- Test với các kích thước màn hình khác nhau

Chúc bạn thành công! 🎉

