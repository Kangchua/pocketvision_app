# 📱 Hướng dẫn cài đặt app lên iPhone sau khi build thành công

## ✅ Bước 1: Download app từ GitHub Actions

1. **Vào GitHub repository:**
   - Mở repository trên GitHub
   - Click tab **Actions**

2. **Tìm workflow run thành công:**
   - Chọn workflow run vừa chạy thành công (có dấu ✅ xanh)
   - Scroll xuống phần **Artifacts**

3. **Download artifact:**
   - Click vào **ios-build**
   - File sẽ được download dưới dạng `.zip`
   - Giải nén file `.zip`

4. **Tìm file app:**
   - Trong thư mục giải nén, tìm file `Runner.app` (thư mục) hoặc `Runner.app.zip`
   - **Nếu không có file `.ipa`:** Xem hướng dẫn `HUONG_DAN_TAO_IPA.md` để tạo file IPA
   - Hoặc dùng script tự động: `create-ipa.ps1`

---

## 📲 Bước 2: Cài đặt app lên iPhone

### **Cách 1: Sideloadly (Khuyến nghị - Dễ nhất)**

1. **Download Sideloadly:**
   - Truy cập: https://sideloadly.io
   - Download phiên bản Windows
   - Cài đặt Sideloadly

2. **Cài iTunes (QUAN TRỌNG):**
   - Sideloadly cần iTunes để nhận diện iPhone
   - Download: https://www.apple.com/itunes/download
   - Hoặc từ Microsoft Store: Tìm "iTunes"
   - Cài đặt iTunes và khởi động lại máy tính

3. **Kết nối iPhone:**
   - Kết nối iPhone với máy Windows qua cáp USB
   - **Mở khóa iPhone** (quan trọng!)
   - Sẽ có popup: **"Trust This Computer?"**
   - Click **"Trust"** và nhập passcode
   - Mở **Settings > General > VPN & Device Management** trên iPhone
   - Đảm bảo đã trust máy tính

3. **Kiểm tra Sideloadly nhận iPhone:**
   - Mở Sideloadly
   - Kiểm tra có hiện tên iPhone không?
   - Nếu không thấy → Xem hướng dẫn: `HUONG_DAN_KHAC_PHUC_SIDELOADLY.md`

4. **Tạo file IPA (nếu chưa có):**
   - Nếu chỉ có `Runner.app` (thư mục), cần tạo file `.ipa` trước
   - **Cách nhanh:** Dùng PowerShell script:
     ```powershell
     cd "thư-mục-chứa-Runner.app"
     .\create-ipa.ps1
     ```
   - Hoặc xem hướng dẫn chi tiết: `HUONG_DAN_TAO_IPA.md`

5. **Cài đặt app:**
   - Kéo thả file `Runner.ipa` (hoặc `Runner.app`) vào Sideloadly
   - Hoặc click **"Select IPA/APP"** và chọn file
   - Nhập **Apple ID** của bạn
   - Click **"Start"**
   - Đợi quá trình cài đặt hoàn tất (2-5 phút)

6. **Trust app trên iPhone:**
   - Vào **Settings > General > VPN & Device Management**
   - Tìm Apple ID của bạn
   - Click **"Trust [Your Apple ID]"**
   - Xác nhận **"Trust"**

7. **Chạy app:**
   - Tìm app **"Pocketvision App"** trên iPhone
   - Mở app và sử dụng!

---

### **Cách 2: AltStore (Cần cài AltServer)**

1. **Cài AltServer trên Windows:**
   - Download: https://altstore.io
   - Cài đặt AltServer
   - Chạy AltServer

2. **Cài AltStore trên iPhone:**
   - Mở Safari trên iPhone
   - Truy cập: https://altstore.io
   - Download và cài AltStore

3. **Cài app qua AltStore:**
   - Mở AltStore trên iPhone
   - Tab **"My Apps"**
   - Click **"+"** ở góc trên
   - Chọn file `Runner.app` hoặc `.ipa`
   - Đợi cài đặt xong

---

### **Cách 3: 3uTools (Windows)**

1. **Download 3uTools:**
   - Truy cập: https://www.3u.com
   - Download và cài đặt 3uTools

2. **Kết nối iPhone:**
   - Kết nối iPhone qua USB
   - Trust máy tính trên iPhone

3. **Cài app:**
   - Mở 3uTools
   - Chọn tab **"Apps"**
   - Click **"Install"**
   - Chọn file `Runner.app` hoặc `.ipa`
   - Đợi cài đặt xong

---

## ⚙️ Bước 3: Cấu hình kết nối với backend

### **Kiểm tra cấu hình API:**

File `lib/config/api_config.dart` đã được cấu hình với IP của bạn:
```dart
static const String serverIp = '192.168.100.194';
```

### **Đảm bảo:**

1. ✅ **Backend đang chạy trên Windows:**
   ```powershell
   cd PBL6-vision-money\back\ledger
   .\mvnw spring-boot:run
   ```

2. ✅ **iPhone và Windows cùng WiFi:**
   - Kiểm tra cả hai đều kết nối cùng mạng WiFi
   - IP của Windows: `192.168.100.194`

3. ✅ **Firewall Windows cho phép port 8081:**
   - Mở **Windows Defender Firewall**
   - Cho phép port `8081` qua firewall
   - Hoặc tạm thời tắt firewall để test

4. ✅ **Test kết nối từ iPhone:**
   - Mở Safari trên iPhone
   - Truy cập: `http://192.168.100.194:8081/api/auth/test`
   - Nếu thấy response → Kết nối OK ✅

---

## 🧪 Bước 4: Test app

1. **Mở app trên iPhone:**
   - Tìm icon **"Pocketvision App"**
   - Mở app

2. **Test đăng ký/đăng nhập:**
   - Tạo tài khoản mới hoặc đăng nhập
   - Kiểm tra kết nối với backend

3. **Test các chức năng:**
   - Tạo chi tiêu
   - Xem báo cáo
   - Quản lý ngân sách
   - Xem hóa đơn

---

## ⚠️ Lưu ý quan trọng

### **Nếu Sideloadly không tìm thấy iPhone:**
- ✅ Đảm bảo đã cài **iTunes** hoặc **Apple Mobile Device Support**
- ✅ Đã **trust máy tính** trên iPhone
- ✅ iPhone đã được **mở khóa**
- ✅ Đã thử **cáp USB khác** hoặc **cổng USB khác**
- 📖 Xem hướng dẫn chi tiết: `HUONG_DAN_KHAC_PHUC_SIDELOADLY.md`

---

### **App sẽ hết hạn sau 7 ngày:**
- Apps cài bằng Sideloadly/AltStore chỉ có hiệu lực 7 ngày
- Sau 7 ngày, cần cài lại app
- Hoặc dùng Apple Developer Account ($99/năm) để cài app 1 năm

### **Nếu gặp lỗi "Untrusted Developer":**
1. Vào **Settings > General > VPN & Device Management**
2. Tìm Apple ID của bạn
3. Click **"Trust"**

### **Nếu app không kết nối được backend:**
1. Kiểm tra iPhone và Windows cùng WiFi
2. Kiểm tra backend đang chạy
3. Kiểm tra firewall Windows
4. Test từ Safari trên iPhone

### **Nếu muốn cập nhật app:**
1. Build lại trên GitHub Actions
2. Download file mới
3. Cài đặt lại bằng Sideloadly/AltStore

---

## 🎉 Hoàn thành!

Bây giờ bạn đã có app chạy trên iPhone! 

**Các bước tóm tắt:**
1. ✅ Download `Runner.app` từ GitHub Actions
2. ✅ Cài đặt bằng Sideloadly/AltStore/3uTools
3. ✅ Trust app trên iPhone
4. ✅ Đảm bảo backend đang chạy và cùng WiFi
5. ✅ Test app!

**Chúc bạn sử dụng app thành công! 🚀**

