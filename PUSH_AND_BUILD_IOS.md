# Hướng dẫn Push Code và Build iOS

## 🚀 Bước 1: Push Code lên GitHub

### Kiểm tra Git hiện tại

```powershell
cd "D:\Hoa new\pocketvision_app"
git status
git remote -v
```

### Thêm remote và push (nếu chưa có)

```powershell
# Nếu chưa có remote
git remote add origin https://github.com/Kangchua/pocketvision_app.git

# Hoặc nếu đã có remote nhưng sai URL
git remote set-url origin https://github.com/Kangchua/pocketvision_app.git

# Kiểm tra lại
git remote -v
```

### Commit và Push code

```powershell
# Kiểm tra thay đổi
git status

# Thêm tất cả file
git add .

# Commit
git commit -m "Update: Add AI server integration and config updates"

# Push lên GitHub
git push -u origin main
```

**Lưu ý:** Nếu yêu cầu authentication:
- Dùng **Personal Access Token** thay vì password
- Hoặc dùng **GitHub CLI**: `gh auth login`

---

## ⚡ Các Cách Build iOS Nhanh Hơn GitHub Actions

### ✅ Cách 1: Build Local trên Mac (NHANH NHẤT - 2-5 phút)

**Yêu cầu:** Có Mac hoặc MacBook

```bash
# 1. Clone code từ GitHub
git clone https://github.com/Kangchua/pocketvision_app.git
cd pocketvision_app

# 2. Cài đặt dependencies
flutter pub get
cd ios && pod install && cd ..

# 3. Build iOS
flutter build ios --release --no-codesign

# 4. Tạo IPA (nếu cần)
cd build/ios/iphoneos
mkdir -p Payload
cp -r Runner.app Payload/
zip -r Runner.ipa Payload
```

**Thời gian:** 2-5 phút  
**Ưu điểm:** Nhanh nhất, không cần chờ queue  
**Nhược điểm:** Cần có Mac

---

### ✅ Cách 2: Codemagic (Cloud Build - 5-10 phút)

**Website:** https://codemagic.io

**Ưu điểm:**
- Build nhanh hơn GitHub Actions (5-10 phút vs 10-20 phút)
- Có free tier (500 phút/tháng)
- Tự động tạo IPA
- Hỗ trợ nhiều platform

**Cách setup:**

1. **Đăng ký Codemagic:**
   - Vào https://codemagic.io
   - Đăng nhập bằng GitHub account
   - Kết nối repository `Kangchua/pocketvision_app`

2. **Tạo workflow:**
   - Codemagic sẽ tự detect Flutter project
   - Chọn iOS build
   - Cấu hình signing (nếu cần)

3. **Build:**
   - Click "Start new build"
   - Chọn branch `main`
   - Đợi 5-10 phút
   - Download IPA từ Codemagic dashboard

**Thời gian:** 5-10 phút  
**Chi phí:** Free tier đủ dùng cho personal project

---

### ✅ Cách 3: AppCircle (Cloud Build - 5-8 phút)

**Website:** https://appcircle.io

**Ưu điểm:**
- Build nhanh (5-8 phút)
- Free tier (100 builds/tháng)
- Tự động tạo IPA
- UI đẹp, dễ dùng

**Cách setup:**

1. **Đăng ký AppCircle:**
   - Vào https://appcircle.io
   - Đăng nhập bằng GitHub
   - Kết nối repository

2. **Cấu hình:**
   - Chọn Flutter project
   - Cấu hình iOS build
   - Setup signing (nếu cần)

3. **Build:**
   - Click "Build Now"
   - Đợi 5-8 phút
   - Download IPA

**Thời gian:** 5-8 phút  
**Chi phí:** Free tier 100 builds/tháng

---

### ✅ Cách 4: Xcode Cloud (Apple Official - 10-15 phút)

**Yêu cầu:** Apple Developer Account ($99/năm)

**Ưu điểm:**
- Official của Apple
- Tích hợp tốt với Xcode
- Free với Apple Developer Account

**Cách setup:**

1. **Mở project trong Xcode:**
   ```bash
   cd pocketvision_app
   open ios/Runner.xcworkspace
   ```

2. **Enable Xcode Cloud:**
   - Xcode > Product > Cloud > Create Cloud Workflow
   - Chọn repository trên GitHub
   - Cấu hình build

3. **Build:**
   - Xcode sẽ tự động build khi push code
   - Hoặc trigger manual từ Xcode

**Thời gian:** 10-15 phút  
**Chi phí:** Cần Apple Developer Account

---

### ✅ Cách 5: GitHub Actions (Hiện tại - 10-20 phút)

**Ưu điểm:**
- Free với GitHub
- Tự động build khi push
- Không cần setup thêm

**Nhược điểm:**
- Chậm nhất (10-20 phút)
- Phải chờ queue Mac runner

**Cách dùng:**

1. **Push code lên GitHub** (đã có workflow)
2. **Vào Actions tab** trên GitHub
3. **Chọn workflow "Build iOS App"**
4. **Click "Run workflow"** hoặc đợi auto-build
5. **Download artifact** sau khi build xong

**Thời gian:** 10-20 phút  
**Chi phí:** Free

---

## 📊 So sánh các phương pháp

| Phương pháp | Thời gian | Chi phí | Độ khó | Khuyến nghị |
|------------|-----------|---------|--------|-------------|
| **Build Local (Mac)** | 2-5 phút | Free | Dễ | ⭐⭐⭐⭐⭐ |
| **Codemagic** | 5-10 phút | Free tier | Dễ | ⭐⭐⭐⭐ |
| **AppCircle** | 5-8 phút | Free tier | Dễ | ⭐⭐⭐⭐ |
| **Xcode Cloud** | 10-15 phút | $99/năm | Trung bình | ⭐⭐⭐ |
| **GitHub Actions** | 10-20 phút | Free | Dễ | ⭐⭐⭐ |

---

## 🎯 Khuyến nghị

### Nếu có Mac:
→ **Build Local** (nhanh nhất, miễn phí)

### Nếu không có Mac:
→ **Codemagic** hoặc **AppCircle** (nhanh, free tier đủ dùng)

### Nếu đã có Apple Developer Account:
→ **Xcode Cloud** (official, tích hợp tốt)

### Nếu không muốn setup thêm:
→ **GitHub Actions** (đã có sẵn, chỉ cần push code)

---

## 🔧 Lệnh Push Code Nhanh (Copy-paste)

```powershell
# Di chuyển vào thư mục
cd "D:\Hoa new\pocketvision_app"

# Kiểm tra remote
git remote -v

# Nếu chưa có remote, thêm:
git remote add origin https://github.com/Kangchua/pocketvision_app.git

# Hoặc cập nhật remote:
git remote set-url origin https://github.com/Kangchua/pocketvision_app.git

# Kiểm tra thay đổi
git status

# Thêm tất cả file
git add .

# Commit
git commit -m "Update: Add AI server integration"

# Push lên GitHub
git push -u origin main
```

---

## 📱 Sau khi Build xong

### Nếu build bằng GitHub Actions/Codemagic/AppCircle:

1. **Download artifact** (file `.ipa` hoặc `Runner.app.zip`)
2. **Tạo IPA** (nếu cần) - xem `HUONG_DAN_TAO_IPA.md`
3. **Cài lên iPhone** bằng Sideloadly hoặc 3uTools

### Nếu build local trên Mac:

1. **File đã sẵn sàng** tại `build/ios/iphoneos/Runner.app`
2. **Tạo IPA** (nếu cần):
   ```bash
   cd build/ios/iphoneos
   mkdir -p Payload
   cp -r Runner.app Payload/
   zip -r Runner.ipa Payload
   ```
3. **Cài lên iPhone** bằng Xcode hoặc Sideloadly

---

## ⚠️ Lưu ý

1. **Personal Access Token:**
   - Nếu GitHub yêu cầu authentication
   - Tạo token: GitHub > Settings > Developer settings > Personal access tokens
   - Quyền: `repo` (full control)

2. **Signing:**
   - Build `--no-codesign` không cần Apple Developer Account
   - Để cài lên iPhone, cần signing (qua Sideloadly hoặc Xcode)

3. **Cập nhật AI Server URL:**
   - Nếu ngrok URL thay đổi, cập nhật trong `lib/config/api_config.dart`
   - Commit và push lại

---

**Chúc bạn build thành công! 🎉**


