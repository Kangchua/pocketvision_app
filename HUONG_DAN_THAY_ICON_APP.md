# Hướng Dẫn Thay Đổi Icon App

## 📍 Vị trí các file icon hiện tại:

### Android:
- `android/app/src/main/res/mipmap-*/ic_launcher.png`
  - `mipmap-mdpi/` - 48x48
  - `mipmap-hdpi/` - 72x72
  - `mipmap-xhdpi/` - 96x96
  - `mipmap-xxhdpi/` - 144x144
  - `mipmap-xxxhdpi/` - 192x192

### iOS:
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

### Web:
- `web/favicon.png`
- `web/icons/Icon-*.png`

## 🎨 Cách thay đổi icon (Khuyến nghị - Tự động):

### Bước 1: Tạo icon chính
1. Tạo một file icon PNG với kích thước **1024x1024 pixels**
2. Đặt tên file là `app_icon.png`
3. Tạo thư mục `assets/icon/` trong project (nếu chưa có)
4. Đặt file `app_icon.png` vào thư mục `assets/icon/`

### Bước 2: Cập nhật cấu hình
File `pubspec.yaml` đã được cấu hình sẵn:
```yaml
flutter_launcher_icons:
  android: true
  ios: true
  web: true
  image_path: "assets/icon/app_icon.png"
  adaptive_icon_background: "#0F9C63"  # Màu primary của app
```

### Bước 3: Generate icons tự động
Chạy các lệnh sau trong terminal:
```bash
cd pocketvision_app
flutter pub get
flutter pub run flutter_launcher_icons
```

Lệnh này sẽ tự động:
- ✅ Tạo tất cả các kích thước icon cho Android
- ✅ Tạo icon cho iOS
- ✅ Tạo icon cho Web
- ✅ Tạo adaptive icon cho Android (với màu nền #0F9C63)

### Bước 4: Rebuild app
```bash
flutter clean
flutter pub get
flutter run
```

## 🎨 Cách thay đổi icon thủ công:

### Android:
1. Thay thế các file trong `android/app/src/main/res/mipmap-*/ic_launcher.png`
2. Đảm bảo đúng kích thước cho từng thư mục

### iOS:
1. Mở Xcode: `ios/Runner.xcworkspace`
2. Chọn `Runner` > `Assets.xcassets` > `AppIcon`
3. Kéo thả các icon vào các ô tương ứng

### Web:
1. Thay `web/favicon.png` (kích thước 512x512)
2. Thay các file trong `web/icons/`:
   - `Icon-192.png` (192x192)
   - `Icon-512.png` (512x512)
   - `Icon-maskable-192.png` (192x192)
   - `Icon-maskable-512.png` (512x512)

## 💡 Lưu ý:

1. **Icon nên có nền trong suốt** (transparent background) hoặc màu nền phù hợp
2. **Android Adaptive Icon**: Nếu muốn tùy chỉnh adaptive icon riêng:
   - Tạo `assets/icon/app_icon_foreground.png` (1024x1024)
   - Tạo `assets/icon/app_icon_background.png` (1024x1024) hoặc chỉ dùng màu
   - Cập nhật `pubspec.yaml`:
     ```yaml
     adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
     adaptive_icon_background: "#0F9C63"  # hoặc đường dẫn đến file
     ```

3. **Màu nền adaptive icon**: Hiện tại là `#0F9C63` (màu primary của app). Có thể thay đổi trong `pubspec.yaml`.

4. **Sau khi thay đổi icon**, cần:
   - Xóa app cũ trên thiết bị
   - Rebuild và cài đặt lại app mới

## 🔧 Troubleshooting:

Nếu gặp lỗi khi generate icons:
```bash
# Xóa cache và thử lại
flutter clean
flutter pub get
flutter pub run flutter_launcher_icons
```

Nếu icon không hiển thị đúng:
- Kiểm tra lại kích thước file (phải đúng 1024x1024)
- Đảm bảo file không bị corrupt
- Thử với file PNG khác

