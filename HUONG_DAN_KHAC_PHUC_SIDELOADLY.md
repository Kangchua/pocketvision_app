# 🔧 Khắc phục lỗi Sideloadly không tìm thấy iPhone

## ⚠️ Vấn đề: Sideloadly không nhận diện iPhone

Nếu Sideloadly không tìm thấy iPhone dù đã cắm USB, thử các bước sau:

---

## ✅ Giải pháp 1: Trust máy tính trên iPhone

1. **Kết nối iPhone với máy Windows qua USB**
2. **Trên iPhone:**
   - Mở khóa iPhone (nếu bị khóa)
   - Sẽ có popup: **"Trust This Computer?"**
   - Click **"Trust"**
   - Nhập passcode của iPhone
3. **Kiểm tra lại Sideloadly:**
   - Đóng và mở lại Sideloadly
   - Click **"Refresh"** hoặc **"Detect Devices"**

---

## ✅ Giải pháp 2: Cài đặt iTunes/Apple Mobile Device Support

Sideloadly cần **iTunes** hoặc **Apple Mobile Device Support** để nhận diện iPhone.

### **Option A: Cài iTunes (Khuyến nghị)**

1. **Download iTunes:**
   - Truy cập: https://www.apple.com/itunes/download
   - Hoặc từ Microsoft Store: Tìm "iTunes"
   - Download và cài đặt iTunes

2. **Khởi động lại máy tính** (sau khi cài iTunes)

3. **Kết nối iPhone lại:**
   - Rút và cắm lại cáp USB
   - Trust máy tính trên iPhone
   - Mở lại Sideloadly

### **Option B: Chỉ cài Apple Mobile Device Support**

1. **Download iTunes:**
   - Download iTunes từ Apple
   - Khi cài, chọn **"Custom Install"**
   - Chỉ chọn **"Apple Mobile Device Support"**
   - Bỏ chọn các phần khác
   - Cài đặt

2. **Khởi động lại máy tính**

---

## ✅ Giải pháp 3: Kiểm tra cáp USB và cổng

1. **Thử cáp USB khác:**
   - Cáp USB có thể bị lỗi
   - Thử cáp chính hãng của Apple

2. **Thử cổng USB khác:**
   - Thử cổng USB 2.0 (thay vì USB 3.0)
   - Thử cổng USB ở mặt sau máy tính (thường ổn định hơn)

3. **Kiểm tra cáp:**
   - Đảm bảo cáp không bị lỏng
   - Đảm bảo cáp hỗ trợ data (không phải chỉ sạc)

---

## ✅ Giải pháp 4: Cài đặt driver USB

1. **Mở Device Manager:**
   - Nhấn `Win + X`
   - Chọn **"Device Manager"**

2. **Kiểm tra iPhone:**
   - Tìm **"Apple iPhone"** hoặc **"Portable Devices"**
   - Nếu có dấu **⚠️** (warning), click chuột phải
   - Chọn **"Update driver"**
   - Chọn **"Search automatically for drivers"**

3. **Nếu không tìm thấy driver:**
   - Download **iTunes** (sẽ tự động cài driver)
   - Hoặc download **Apple Mobile Device Support** riêng

---

## ✅ Giải pháp 5: Khởi động lại dịch vụ Apple Mobile Device

1. **Mở Services:**
   - Nhấn `Win + R`
   - Gõ `services.msc`
   - Nhấn Enter

2. **Tìm và khởi động lại:**
   - Tìm **"Apple Mobile Device Service"**
   - Click chuột phải > **"Restart"**
   - Hoặc **"Start"** nếu đang dừng

3. **Khởi động lại Sideloadly**

---

## ✅ Giải pháp 6: Cài đặt lại Sideloadly

1. **Gỡ cài đặt Sideloadly:**
   - Settings > Apps > Sideloadly > Uninstall

2. **Download lại Sideloadly:**
   - Truy cập: https://sideloadly.io
   - Download phiên bản mới nhất

3. **Cài đặt lại:**
   - Chạy installer với quyền Administrator
   - (Click chuột phải > Run as administrator)

---

## ✅ Giải pháp 7: Kiểm tra Windows Defender / Antivirus

1. **Tạm thời tắt Windows Defender:**
   - Settings > Privacy & Security > Windows Security
   - Virus & threat protection
   - Tạm thời tắt Real-time protection

2. **Thêm Sideloadly vào exception:**
   - Windows Security > Virus & threat protection
   - Manage settings > Exclusions
   - Add exclusion > Folder
   - Chọn thư mục cài Sideloadly

---

## ✅ Giải pháp 8: Sử dụng AltStore thay thế

Nếu Sideloadly vẫn không hoạt động, thử **AltStore**:

1. **Download AltServer:**
   - Truy cập: https://altstore.io
   - Download AltServer cho Windows

2. **Cài AltStore trên iPhone:**
   - Cài AltServer trên Windows
   - Chạy AltServer
   - Mở Safari trên iPhone
   - Truy cập: https://altstore.io
   - Download và cài AltStore

3. **Cài app qua AltStore:**
   - Mở AltStore trên iPhone
   - Tab "My Apps" > "+"
   - Chọn file `Runner.app`

---

## ✅ Giải pháp 9: Sử dụng 3uTools

**3uTools** là công cụ thay thế tốt:

1. **Download 3uTools:**
   - Truy cập: https://www.3u.com
   - Download và cài đặt

2. **Kết nối iPhone:**
   - Kết nối iPhone qua USB
   - Trust máy tính trên iPhone
   - 3uTools sẽ tự động nhận diện

3. **Cài app:**
   - Tab **"Apps"**
   - Click **"Install"**
   - Chọn file `Runner.app`

---

## 🔍 Kiểm tra nhanh

### **Checklist:**

- [ ] iPhone đã được mở khóa?
- [ ] Đã trust máy tính trên iPhone?
- [ ] Đã cài iTunes hoặc Apple Mobile Device Support?
- [ ] Cáp USB có hỗ trợ data?
- [ ] Đã thử cổng USB khác?
- [ ] Đã khởi động lại máy tính?
- [ ] Đã khởi động lại Sideloadly?
- [ ] Windows Defender có chặn không?

---

## 📱 Test kết nối

Sau khi cài iTunes, test xem Windows có nhận iPhone không:

1. **Mở File Explorer**
2. **Kiểm tra:**
   - Có hiện **"Apple iPhone"** không?
   - Có thể truy cập ảnh/video trên iPhone không?

Nếu Windows nhận iPhone → Sideloadly sẽ nhận được
Nếu Windows không nhận → Cần cài iTunes/driver

---

## 💡 Tips

1. **Luôn trust máy tính** khi kết nối lần đầu
2. **Sử dụng cáp chính hãng** của Apple
3. **Khởi động lại** sau khi cài iTunes
4. **Chạy Sideloadly với quyền Administrator**

---

## 🆘 Vẫn không được?

Nếu đã thử tất cả các bước trên mà vẫn không được:

1. **Thử máy tính khác** (để xác định lỗi ở iPhone hay máy tính)
2. **Thử iPhone khác** (để xác định lỗi ở cáp/USB)
3. **Liên hệ support Sideloadly:** https://sideloadly.io/support
4. **Sử dụng AltStore hoặc 3uTools** thay thế

---

**Chúc bạn thành công! 🎉**




