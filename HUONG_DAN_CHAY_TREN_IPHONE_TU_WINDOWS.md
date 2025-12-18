# 🪟 Chạy Flutter App trên iPhone từ Windows

## ⚠️ Vấn đề

**Flutter KHÔNG THỂ build iOS app trực tiếp trên Windows** vì:
- iOS build cần Xcode (chỉ có trên macOS)
- Apple yêu cầu code signing với Apple Developer tools

## ✅ Các giải pháp

### 🎯 Giải pháp 1: Sử dụng Mac Cloud/Remote (Khuyến nghị)

#### Option A: MacStadium / MacinCloud (Trả phí)
- **MacStadium:** $99/tháng - Mac cloud chuyên dụng
- **MacinCloud:** $20-50/tháng - Mac remote desktop
- **Ưu điểm:** Mac thật, hiệu suất tốt, ổn định
- **Nhược điểm:** Phải trả phí

#### Option B: GitHub Actions với Mac Runner (MIỄN PHÍ)
Sử dụng GitHub Actions để build iOS app tự động trên Mac cloud của GitHub.

**Cách setup:**

1. **Tạo file `.github/workflows/ios-build.yml`:**
```yaml
name: Build iOS App

on:
  workflow_dispatch:  # Chạy thủ công
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.24.0'
        channel: 'stable'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Build iOS
      run: |
        cd ios
        pod install
        cd ..
        flutter build ios --release --no-codesign
    
    - name: Upload artifact
      uses: actions/upload-artifact@v3
      with:
        name: ios-build
        path: build/ios/iphoneos/Runner.app
```

2. **Push code lên GitHub:**
```bash
git add .
git commit -m "Add iOS build workflow"
git push
```

3. **Chạy workflow:**
   - Vào GitHub > Actions
   - Chọn workflow "Build iOS App"
   - Click "Run workflow"
   - Download artifact sau khi build xong

**Ưu điểm:** Miễn phí, tự động
**Nhược điểm:** Cần GitHub account, không thể debug trực tiếp

---

### 🎯 Giải pháp 2: Sử dụng Codemagic (MIỄN PHÍ - 500 phút/tháng)

1. **Đăng ký:** https://codemagic.io
2. **Kết nối GitHub/GitLab repository**
3. **Setup build config:**
   - Chọn iOS platform
   - Codemagic tự động detect Flutter project
4. **Build và download .ipa file**

**Ưu điểm:** 
- Miễn phí 500 phút/tháng
- UI đẹp, dễ sử dụng
- Tự động build khi push code

**Nhược điểm:** 
- Giới hạn 500 phút/tháng
- Cần upload code lên Git

---

### 🎯 Giải pháp 3: Mượn/Thuê Mac tạm thời

1. **Mượn Mac từ bạn bè/đồng nghiệp**
2. **Thuê Mac theo giờ:**
   - MacinCloud: $1-2/giờ
   - AWS EC2 Mac instances: ~$1.08/giờ

**Cách làm:**
```bash
# Trên Mac:
cd pocketvision_app
flutter run
```

**Ưu điểm:** Kiểm soát hoàn toàn, có thể debug
**Nhược điểm:** Cần Mac thật, tốn phí

---

### 🎯 Giải pháp 4: Build trên Mac và chuyển file .ipa

Nếu bạn có Mac (dù chỉ 1 lần):

1. **Build trên Mac:**
```bash
cd pocketvision_app
flutter build ios --release
```

2. **Tạo .ipa file:**
   - Mở Xcode
   - Archive project
   - Export .ipa

3. **Cài đặt trên iPhone:**
   - Dùng **AltStore** hoặc **Sideloadly** (Windows)
   - Hoặc dùng **3uTools** (Windows)

**Hướng dẫn chi tiết:**
- **AltStore:** https://altstore.io
- **Sideloadly:** https://sideloadly.io
- **3uTools:** https://www.3u.com

---

### 🎯 Giải pháp 5: Sử dụng Flutter Web (Tạm thời)

Nếu chỉ cần test UI/UX, có thể chạy trên web:

```bash
flutter run -d chrome
```

Sau đó mở trên iPhone Safari (cùng mạng WiFi):
- Tìm IP của máy Windows
- Truy cập: `http://192.168.100.194:xxxxx` (port hiển thị khi chạy)

**Ưu điểm:** Nhanh, không cần Mac
**Nhược điểm:** Không phải native app, một số tính năng không hoạt động

---

## 🚀 Giải pháp khuyến nghị cho bạn

Vì bạn đang dùng Windows và có iPhone 13, tôi khuyến nghị:

### **Option 1: GitHub Actions (Miễn phí)**
1. Tạo GitHub repository
2. Setup workflow như trên
3. Build và download .ipa
4. Cài đặt bằng AltStore/Sideloadly

### **Option 2: Codemagic (Dễ nhất)**
1. Đăng ký Codemagic
2. Connect repository
3. Build và download
4. Cài đặt trên iPhone

### **Option 3: Thuê Mac 1 lần**
1. Thuê Mac cloud 1-2 giờ
2. Build app
3. Export .ipa
4. Cài đặt trên iPhone

---

## 📱 Cài đặt .ipa trên iPhone (Sau khi có file)

### Cách 1: Sideloadly (Windows)
1. Download: https://sideloadly.io
2. Kết nối iPhone qua USB
3. Mở Sideloadly
4. Chọn .ipa file
5. Nhập Apple ID
6. Click "Start"

### Cách 2: AltStore (iPhone)
1. Cài AltStore trên iPhone (cần Mac hoặc Windows với AltServer)
2. Mở AltStore
3. Chọn .ipa file
4. Install

### Cách 3: 3uTools (Windows)
1. Download: https://www.3u.com
2. Kết nối iPhone
3. Chọn "Apps" > "Install"
4. Chọn .ipa file

---

## ⚙️ Cấu hình cho Windows Development

Dù không build iOS trên Windows, bạn vẫn có thể:

1. **Develop trên Windows:**
   - Code, test logic
   - Chạy trên Android emulator
   - Chạy trên web

2. **Build iOS định kỳ:**
   - Dùng GitHub Actions hoặc Codemagic
   - Build khi cần release

3. **Hot Reload trên iOS:**
   - Cần Mac để chạy `flutter run`
   - Hoặc dùng remote Mac

---

## 🔧 Setup GitHub Actions (Chi tiết)

### Bước 1: Tạo GitHub Repository
```bash
cd pocketvision_app
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/username/pocketvision_app.git
git push -u origin main
```

### Bước 2: Tạo Workflow File
Tạo file: `.github/workflows/ios-build.yml`

```yaml
name: Build iOS

on:
  workflow_dispatch:
  push:
    branches: [ main ]

jobs:
  build-ios:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.24.0'
    
    - name: Get dependencies
      run: flutter pub get
    
    - name: Install CocoaPods
      run: |
        cd ios
        pod install
        cd ..
    
    - name: Build iOS (no codesign)
      run: flutter build ios --release --no-codesign
    
    - name: Archive
      uses: actions/upload-artifact@v3
      with:
        name: ios-app
        path: build/ios/iphoneos/Runner.app
        retention-days: 7
```

### Bước 3: Chạy Workflow
1. Vào GitHub > Actions
2. Chọn "Build iOS"
3. Click "Run workflow"
4. Đợi build xong (5-10 phút)
5. Download artifact

### Bước 4: Cài đặt trên iPhone
Sử dụng Sideloadly hoặc AltStore như hướng dẫn trên.

---

## 💡 Tips

1. **Development workflow:**
   - Code trên Windows
   - Test trên Android/Web
   - Build iOS định kỳ qua CI/CD

2. **Debug trên iOS:**
   - Cần Mac để debug trực tiếp
   - Hoặc dùng remote Mac

3. **Hot Reload:**
   - Chỉ hoạt động khi chạy `flutter run` trên Mac
   - GitHub Actions không hỗ trợ hot reload

---

## ❓ FAQ

**Q: Có cách nào build iOS trực tiếp trên Windows không?**
A: Không, Apple yêu cầu Xcode chỉ chạy trên macOS.

**Q: GitHub Actions có miễn phí không?**
A: Có, miễn phí cho public repos. Private repos có 2000 phút/tháng miễn phí.

**Q: Có thể debug trên iPhone từ Windows không?**
A: Không trực tiếp, nhưng có thể dùng remote Mac hoặc log qua Firebase Crashlytics.

**Q: File .ipa có kích thước bao nhiêu?**
A: Thường 20-50MB, tùy app.

---

## 📞 Hỗ trợ

Nếu gặp vấn đề:
1. Kiểm tra log trong GitHub Actions
2. Đảm bảo code không có lỗi
3. Kiểm tra iOS configuration trong `ios/` folder

**Chúc bạn thành công! 🎉**

