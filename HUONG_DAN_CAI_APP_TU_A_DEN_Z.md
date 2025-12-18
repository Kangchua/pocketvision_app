# 📱 Hướng dẫn cài app lên iPhone từ file ios-build.zip (Từ A đến Z)

## 📦 Bước 1: Giải nén file ios-build.zip

1. **Tìm file `ios-build.zip`:**
   - File đã được tải về và đặt trong thư mục `TEST`
   - Vị trí: `D:\Test\TEST\ios-build.zip`

2. **Giải nén file:**
   - Click chuột phải vào `ios-build.zip`
   - Chọn **"Extract All..."** hoặc **"Extract Here"**
   - Hoặc dùng WinRAR/7-Zip để giải nén

3. **Kiểm tra nội dung sau khi giải nén:**
   - Bạn sẽ thấy:
     - `Runner.app` (thư mục) - Đây là app bundle
     - `Runner.app.zip` (file zip) - File zip của Runner.app (nếu có)

---

## 🔧 Bước 2: Tạo file IPA từ Runner.app

File IPA cần thiết để cài đặt lên iPhone. Có 2 cách:

### **Cách 1: Dùng script PowerShell (Khuyến nghị - Nhanh nhất)**

1. **Copy script `create-ipa.ps1` vào thư mục TEST:**
   - Copy file `create-ipa.ps1` từ thư mục `pocketvision_app`
   - Paste vào thư mục `TEST` (cùng thư mục với `Runner.app`)

2. **Mở PowerShell:**
   - Nhấn `Win + X`
   - Chọn **"Windows PowerShell"** hoặc **"Terminal"**
   - Hoặc nhấn `Win + R`, gõ `powershell`, nhấn Enter

3. **Di chuyển đến thư mục TEST:**
   ```powershell
   cd "D:\Test\TEST"
   ```

4. **Chạy script:**
   ```powershell
   .\create-ipa.ps1
   ```

5. **Kết quả:**
   - Script sẽ tạo file `Runner.ipa` trong thư mục `TEST`
   - Bạn sẽ thấy thông báo: "✅ Đã tạo file Runner.ipa thành công!"

---

### **Cách 2: Tạo IPA thủ công**

1. **Tạo thư mục `Payload`:**
   - Trong thư mục `TEST`, tạo thư mục mới
   - Đặt tên: `Payload` (chú ý: chữ **P viết hoa**)

2. **Copy Runner.app vào Payload:**
   - Copy toàn bộ thư mục `Runner.app`
   - Paste vào trong thư mục `Payload`
   - Cấu trúc: `TEST/Payload/Runner.app/`

3. **Tạo file ZIP:**
   - Click chuột phải vào thư mục `Payload`
   - Chọn **"Send to > Compressed (zipped) folder"**
   - Hoặc dùng WinRAR/7-Zip: Click chuột phải > **"Add to archive"**

4. **Đổi đuôi thành .ipa:**
   - Đổi tên file `Payload.zip` thành `Runner.ipa`
   - Windows sẽ hỏi: "Are you sure you want to change the file extension?"
   - Click **"Yes"**

5. **Xóa thư mục Payload tạm (tùy chọn):**
   - Xóa thư mục `Payload` để giữ gọn

---

## 📲 Bước 3: Cài đặt app lên iPhone bằng Sideloadly

### **3.1. Chuẩn bị**

1. **Cài iTunes (QUAN TRỌNG):**
   - Download: https://www.apple.com/itunes/download
   - Hoặc từ Microsoft Store: Tìm "iTunes"
   - Cài đặt và **khởi động lại máy tính**

2. **Download Sideloadly:**
   - Truy cập: https://sideloadly.io
   - Download phiên bản Windows
   - Cài đặt Sideloadly

3. **Kết nối iPhone:**
   - Dùng cáp USB chính hãng của Apple
   - Kết nối iPhone với máy Windows
   - **Mở khóa iPhone** (quan trọng!)
   - Sẽ có popup: **"Trust This Computer?"**
   - Click **"Trust"** và nhập passcode của iPhone

---

### **3.2. Cài đặt app**

1. **Mở Sideloadly:**
   - Chạy Sideloadly
   - Đảm bảo iPhone đã được nhận diện (hiện tên iPhone ở trên)

2. **Nếu Sideloadly không tìm thấy iPhone:**
   - Xem hướng dẫn: `HUONG_DAN_KHAC_PHUC_SIDELOADLY.md`
   - Đảm bảo đã cài iTunes và trust máy tính

3. **Chọn file app:**
   - Cách 1: Kéo thả file `Runner.ipa` vào cửa sổ Sideloadly
   - Cách 2: Click **"Select IPA/APP"** và chọn file `Runner.ipa`
   - Vị trí file: `D:\Test\TEST\Runner.ipa`

4. **Nhập thông tin:**
   - **Apple ID:** Nhập email Apple ID của bạn
   - **Password:** Nhập mật khẩu Apple ID
   - ⚠️ **Lưu ý:** Apple ID cần bật 2FA (Two-Factor Authentication)

5. **Bắt đầu cài đặt:**
   - Click nút **"Start"**
   - Đợi quá trình cài đặt (2-5 phút)
   - Sẽ có thông báo khi hoàn tất

---

### **3.3. Trust app trên iPhone**

1. **Vào Settings:**
   - Mở **Settings** trên iPhone
   - Vào **General > VPN & Device Management**
   - (Hoặc **General > Device Management** trên iOS cũ hơn)

2. **Trust developer:**
   - Tìm Apple ID của bạn trong danh sách
   - Click vào Apple ID
   - Click **"Trust [Your Apple ID]"**
   - Xác nhận **"Trust"**

3. **Hoàn tất:**
   - App đã sẵn sàng sử dụng!

---

## 🎯 Bước 4: Chạy app và kiểm tra

1. **Tìm app trên iPhone:**
   - Tìm icon **"Pocketvision App"** hoặc **"Runner"** trên màn hình chính
   - Mở app

2. **Kiểm tra kết nối backend:**
   - Đảm bảo backend đang chạy trên Windows:
     ```powershell
     cd "D:\Test\PBL6-vision-money\back\ledger"
     .\mvnw spring-boot:run
     ```
   - Đảm bảo iPhone và Windows cùng WiFi
   - IP backend: `192.168.100.194:8081`

3. **Test đăng nhập:**
   - Tạo tài khoản mới hoặc đăng nhập
   - Kiểm tra các chức năng hoạt động

---

## ⚠️ Lưu ý quan trọng

### **App sẽ hết hạn sau 7 ngày:**
- Apps cài bằng Sideloadly chỉ có hiệu lực 7 ngày
- Sau 7 ngày, cần cài lại app
- Hoặc dùng Apple Developer Account ($99/năm) để cài app 1 năm

### **Nếu gặp lỗi "Untrusted Developer":**
1. Vào **Settings > General > VPN & Device Management**
2. Tìm Apple ID của bạn
3. Click **"Trust"**

### **Nếu app không kết nối được backend:**
1. Kiểm tra iPhone và Windows cùng WiFi
2. Kiểm tra backend đang chạy
3. Kiểm tra firewall Windows (cho phép port 8081)
4. Test từ Safari trên iPhone: `http://192.168.100.194:8081/api/auth/test`

### **Nếu Sideloadly không tìm thấy iPhone:**
- Xem hướng dẫn: `HUONG_DAN_KHAC_PHUC_SIDELOADLY.md`
- Đảm bảo đã cài iTunes
- Đảm bảo đã trust máy tính trên iPhone

---

## 📋 Checklist nhanh

Trước khi cài đặt, đảm bảo:

- [ ] Đã giải nén file `ios-build.zip`
- [ ] Đã tạo file `Runner.ipa` từ `Runner.app`
- [ ] Đã cài iTunes trên Windows
- [ ] Đã cài Sideloadly
- [ ] iPhone đã được kết nối qua USB
- [ ] iPhone đã trust máy tính
- [ ] Sideloadly đã nhận diện iPhone
- [ ] Đã có Apple ID và mật khẩu

---

## 🎉 Hoàn thành!

Bây giờ bạn đã có app chạy trên iPhone!

**Các bước tóm tắt:**
1. ✅ Giải nén `ios-build.zip`
2. ✅ Tạo `Runner.ipa` từ `Runner.app`
3. ✅ Cài đặt bằng Sideloadly
4. ✅ Trust app trên iPhone
5. ✅ Chạy app và test!

**Chúc bạn sử dụng app thành công! 🚀**

---

## 🆘 Cần giúp đỡ?

Nếu gặp vấn đề:

1. **Sideloadly không tìm thấy iPhone:**
   - Xem: `HUONG_DAN_KHAC_PHUC_SIDELOADLY.md`

2. **Không tạo được file IPA:**
   - Xem: `HUONG_DAN_TAO_IPA.md`

3. **App không chạy được:**
   - Kiểm tra backend đang chạy
   - Kiểm tra kết nối WiFi
   - Kiểm tra firewall



