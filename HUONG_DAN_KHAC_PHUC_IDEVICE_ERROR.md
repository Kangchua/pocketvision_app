# 🔧 Khắc phục lỗi: IDEVICE_E_NO_DEVICE

## ⚠️ Lỗi bạn gặp:
```
FAILED: Call to idevice_new_with_options failed: IDEVICE_E_NO_DEVICE
Waiting for the device 00008110-00123D1C3E84401E to re-appear (will wait for at most 3 minutes)
```

**Nguyên nhân:** Sideloadly không thể kết nối với iPhone trong quá trình cài đặt.

---

## ✅ Giải pháp 1: Kiểm tra kết nối iPhone (Quan trọng nhất)

### **Bước 1: Đảm bảo iPhone vẫn kết nối**

1. **Kiểm tra cáp USB:**
   - Đảm bảo cáp USB vẫn được cắm chặt
   - Thử rút và cắm lại cáp
   - Thử cáp USB khác (nếu có)

2. **Kiểm tra iPhone:**
   - **Mở khóa iPhone** (quan trọng!)
   - Đảm bảo iPhone không bị khóa màn hình
   - Đảm bảo iPhone không ở chế độ sleep

3. **Kiểm tra trên Windows:**
   - Mở **File Explorer**
   - Kiểm tra có hiện **"Apple iPhone"** không?
   - Nếu không thấy → iPhone chưa được nhận diện

---

### **Bước 2: Trust lại máy tính**

1. **Trên iPhone:**
   - Mở **Settings > General > VPN & Device Management**
   - Nếu thấy máy tính trong danh sách → Xóa và trust lại
   - Hoặc rút cáp, cắm lại và trust lại

2. **Trust lại:**
   - Rút cáp USB
   - Cắm lại cáp USB
   - Sẽ có popup: **"Trust This Computer?"**
   - Click **"Trust"** và nhập passcode

---

## ✅ Giải pháp 2: Khởi động lại dịch vụ Apple Mobile Device

1. **Mở Services:**
   - Nhấn `Win + R`
   - Gõ `services.msc`
   - Nhấn Enter

2. **Tìm và khởi động lại:**
   - Tìm **"Apple Mobile Device Service"**
   - Click chuột phải → **"Restart"**
   - Đợi dịch vụ khởi động lại (10-20 giây)

3. **Khởi động lại Sideloadly:**
   - Đóng Sideloadly hoàn toàn
   - Mở lại Sideloadly
   - Kết nối iPhone lại

---

## ✅ Giải pháp 3: Khởi động lại iTunes Helper

1. **Mở Task Manager:**
   - Nhấn `Ctrl + Shift + Esc`
   - Hoặc `Ctrl + Alt + Delete` → Task Manager

2. **Tìm và kết thúc:**
   - Tìm **"iTunes Helper"** hoặc **"iTunes.exe"**
   - Click chuột phải → **"End Task"**

3. **Mở lại iTunes:**
   - Mở iTunes một lần
   - Đảm bảo iTunes nhận diện iPhone
   - Đóng iTunes
   - Mở lại Sideloadly

---

## ✅ Giải pháp 4: Cài đặt lại driver USB

1. **Mở Device Manager:**
   - Nhấn `Win + X`
   - Chọn **"Device Manager"**

2. **Kiểm tra iPhone:**
   - Tìm **"Apple iPhone"** hoặc **"Portable Devices"**
   - Nếu có dấu ⚠️ (warning):
     - Click chuột phải → **"Update driver"**
     - Chọn **"Search automatically for drivers"**

3. **Nếu không tìm thấy driver:**
   - Gỡ cài đặt iTunes
   - Download và cài lại iTunes: https://www.apple.com/itunes/download
   - Khởi động lại máy tính

---

## ✅ Giải pháp 5: Thử cổng USB khác

1. **Rút cáp USB khỏi cổng hiện tại**
2. **Cắm vào cổng USB khác:**
   - Thử cổng USB 2.0 (thay vì USB 3.0)
   - Thử cổng USB ở mặt sau máy tính (thường ổn định hơn)
   - Tránh dùng USB hub

3. **Đợi Windows nhận diện iPhone:**
   - Đợi 10-20 giây
   - Kiểm tra File Explorer có hiện iPhone không

4. **Mở lại Sideloadly và thử lại**

---

## ✅ Giải pháp 6: Khởi động lại iPhone

1. **Khởi động lại iPhone:**
   - Nhấn và giữ nút nguồn + nút giảm âm lượng (iPhone X trở lên)
   - Hoặc nhấn và giữ nút nguồn (iPhone cũ hơn)
   - Kéo thanh trượt để tắt
   - Nhấn nút nguồn để bật lại

2. **Kết nối lại:**
   - Cắm cáp USB lại
   - Trust máy tính (nếu được hỏi)
   - Mở lại Sideloadly

---

## ✅ Giải pháp 7: Đóng và mở lại Sideloadly

1. **Đóng Sideloadly hoàn toàn:**
   - Click **X** để đóng
   - Mở Task Manager → Tìm **"Sideloadly"** → End Task

2. **Mở lại Sideloadly:**
   - Chạy Sideloadly với quyền Administrator
   - Click chuột phải → **"Run as administrator"**

3. **Kết nối iPhone lại:**
   - Cắm iPhone lại
   - Đợi Sideloadly nhận diện
   - Thử cài app lại

---

## ✅ Giải pháp 8: Dùng 3uTools thay thế

Nếu Sideloadly vẫn không hoạt động, thử **3uTools**:

1. **Download 3uTools:**
   - Truy cập: https://www.3u.com
   - Download và cài đặt

2. **Kết nối iPhone:**
   - Kết nối iPhone qua USB
   - Trust máy tính trên iPhone
   - 3uTools sẽ tự động nhận diện

3. **Cài app:**
   - Mở 3uTools
   - Tab **"Apps"**
   - Click **"Install"**
   - Chọn file `Runner.ipa`
   - Đợi cài đặt xong

---

## ✅ Giải pháp 9: Kiểm tra cáp USB

1. **Thử cáp USB khác:**
   - Cáp USB có thể bị lỗi
   - Thử cáp chính hãng của Apple
   - Đảm bảo cáp hỗ trợ data (không phải chỉ sạc)

2. **Kiểm tra cáp:**
   - Cáp có bị lỏng không?
   - Cáp có bị hư hỏng không?
   - Thử cắm vào thiết bị khác để test

---

## ✅ Giải pháp 10: Kiểm tra Windows Defender / Antivirus

1. **Tạm thời tắt Windows Defender:**
   - Settings > Privacy & Security > Windows Security
   - Virus & threat protection
   - Tạm thời tắt Real-time protection

2. **Thêm Sideloadly vào exception:**
   - Windows Security > Virus & threat protection
   - Manage settings > Exclusions
   - Add exclusion > Folder
   - Chọn thư mục cài Sideloadly

3. **Thử cài app lại**

---

## 🔍 Checklist nhanh

Trước khi thử lại, đảm bảo:

- [ ] iPhone đã được **mở khóa** (không bị khóa màn hình)
- [ ] Cáp USB **vẫn được cắm chặt**
- [ ] iPhone đã **trust máy tính**
- [ ] Windows **nhận diện iPhone** (hiện trong File Explorer)
- [ ] **iTunes** đã được cài đặt
- [ ] **Apple Mobile Device Service** đang chạy
- [ ] Đã thử **cổng USB khác**
- [ ] Đã **khởi động lại iPhone**
- [ ] Đã **khởi động lại Sideloadly**

---

## 📋 Các bước khắc phục theo thứ tự ưu tiên

1. ✅ **Kiểm tra iPhone vẫn kết nối và mở khóa**
2. ✅ **Trust lại máy tính trên iPhone**
3. ✅ **Khởi động lại Apple Mobile Device Service**
4. ✅ **Thử cổng USB khác**
5. ✅ **Khởi động lại iPhone**
6. ✅ **Khởi động lại Sideloadly với quyền Administrator**
7. ✅ **Cài đặt lại iTunes**
8. ✅ **Dùng 3uTools thay thế**

---

## 🆘 Vẫn không được?

Nếu đã thử tất cả các bước trên mà vẫn không được:

1. **Thử máy tính khác:**
   - Để xác định lỗi ở iPhone hay máy tính

2. **Thử iPhone khác:**
   - Để xác định lỗi ở cáp/USB

3. **Liên hệ support Sideloadly:**
   - https://sideloadly.io/support

4. **Dùng AltStore hoặc 3uTools:**
   - Các công cụ thay thế có thể hoạt động tốt hơn

---

## 💡 Tips để tránh lỗi này

1. **Luôn giữ iPhone mở khóa** trong quá trình cài đặt
2. **Không rút cáp USB** khi đang cài đặt
3. **Đảm bảo cáp USB chính hãng** và còn tốt
4. **Chạy Sideloadly với quyền Administrator**
5. **Đóng các ứng dụng khác** (iTunes, 3uTools) khi dùng Sideloadly

---

**Chúc bạn khắc phục thành công! 🎉**



