# 📦 Hướng dẫn tạo file IPA từ Runner.app trên Windows

## ⚠️ Vấn đề: Không có file .ipa trong artifact

Khi download artifact từ GitHub Actions, bạn sẽ có:
- `Runner.app` (thư mục)
- `Runner.app.zip` (file zip)

Nhưng Sideloadly thường cần file `.ipa`. Đây là cách tạo file IPA:

---

## ✅ Cách 1: Tạo IPA từ Runner.app.zip (Dễ nhất)

### **Bước 1: Giải nén Runner.app.zip**

1. **Download artifact từ GitHub Actions:**
   - Vào GitHub > Actions > Chọn workflow run thành công
   - Download artifact `ios-build`
   - Giải nén file `.zip`

2. **Tìm file Runner.app.zip:**
   - Trong thư mục giải nén, tìm `Runner.app.zip`
   - Nếu không có, xem **Cách 2** bên dưới

### **Bước 2: Tạo cấu trúc IPA**

File IPA thực chất là file ZIP với cấu trúc:
```
YourApp.ipa
└── Payload/
    └── Runner.app/
        └── (các file bên trong)
```

**Cách tạo:**

1. **Tạo thư mục mới:**
   - Tạo thư mục tên `Payload` (chú ý: chữ P viết hoa)

2. **Giải nén Runner.app.zip:**
   - Giải nén `Runner.app.zip`
   - Bạn sẽ có thư mục `Runner.app`

3. **Di chuyển Runner.app vào Payload:**
   - Di chuyển thư mục `Runner.app` vào trong thư mục `Payload`
   - Cấu trúc: `Payload/Runner.app/`

4. **Tạo file ZIP:**
   - Chọn thư mục `Payload`
   - Click chuột phải > **Send to > Compressed (zipped) folder**
   - Hoặc dùng WinRAR/7-Zip: Click chuột phải > **Add to archive**

5. **Đổi đuôi thành .ipa:**
   - Đổi tên file `Payload.zip` thành `Runner.ipa`
   - Windows sẽ hỏi "Are you sure you want to change the file extension?"
   - Click **"Yes"**

6. **Xong! Bây giờ bạn có file `Runner.ipa`** ✅

---

## ✅ Cách 2: Tạo IPA từ thư mục Runner.app

Nếu bạn chỉ có thư mục `Runner.app` (không có file zip):

### **Bước 1: Tạo cấu trúc Payload**

1. **Tạo thư mục `Payload`:**
   - Tạo thư mục mới tên `Payload` (chữ P viết hoa)

2. **Copy Runner.app vào Payload:**
   - Copy toàn bộ thư mục `Runner.app` vào trong `Payload`
   - Cấu trúc: `Payload/Runner.app/`

### **Bước 2: Tạo file ZIP**

1. **Chọn thư mục Payload:**
   - Click chuột phải vào thư mục `Payload`

2. **Tạo ZIP:**
   - Chọn **"Send to > Compressed (zipped) folder"**
   - Hoặc dùng WinRAR/7-Zip: **"Add to archive"**

3. **Đổi đuôi thành .ipa:**
   - Đổi tên `Payload.zip` thành `Runner.ipa`
   - Xác nhận đổi đuôi file

---

## ✅ Cách 3: Dùng PowerShell (Nhanh nhất)

Mở PowerShell và chạy lệnh sau:

```powershell
# Di chuyển đến thư mục chứa Runner.app
cd "D:\Test\pocketvision_app\download"  # Thay đổi đường dẫn của bạn

# Tạo thư mục Payload
New-Item -ItemType Directory -Path "Payload" -Force

# Copy Runner.app vào Payload
Copy-Item -Path "Runner.app" -Destination "Payload\Runner.app" -Recurse

# Tạo file ZIP
Compress-Archive -Path "Payload" -DestinationPath "Runner.zip" -Force

# Đổi đuôi thành .ipa
Rename-Item -Path "Runner.zip" -NewName "Runner.ipa"

# Xóa thư mục Payload tạm (tùy chọn)
Remove-Item -Path "Payload" -Recurse -Force

Write-Host "✅ Đã tạo file Runner.ipa thành công!"
```

---

## ✅ Cách 4: Dùng script tự động

Tạo file `create-ipa.ps1`:

```powershell
# Script tạo IPA từ Runner.app
param(
    [string]$AppPath = "Runner.app",
    [string]$OutputName = "Runner.ipa"
)

Write-Host "📦 Đang tạo file IPA..."

# Kiểm tra Runner.app có tồn tại không
if (-not (Test-Path $AppPath)) {
    Write-Host "❌ Không tìm thấy $AppPath"
    Write-Host "💡 Hãy đảm bảo bạn đang ở đúng thư mục chứa Runner.app"
    exit 1
}

# Tạo thư mục Payload
$PayloadPath = "Payload"
if (Test-Path $PayloadPath) {
    Remove-Item -Path $PayloadPath -Recurse -Force
}
New-Item -ItemType Directory -Path $PayloadPath -Force | Out-Null

# Copy Runner.app vào Payload
Write-Host "📋 Đang copy Runner.app vào Payload..."
Copy-Item -Path $AppPath -Destination "$PayloadPath\Runner.app" -Recurse

# Tạo file ZIP
Write-Host "🗜️  Đang tạo file ZIP..."
$ZipPath = "$OutputName.zip"
if (Test-Path $ZipPath) {
    Remove-Item -Path $ZipPath -Force
}
Compress-Archive -Path $PayloadPath -DestinationPath $ZipPath -Force

# Đổi đuôi thành .ipa
Write-Host "🔄 Đang đổi đuôi thành .ipa..."
if (Test-Path $OutputName) {
    Remove-Item -Path $OutputName -Force
}
Rename-Item -Path $ZipPath -NewName $OutputName

# Xóa thư mục Payload tạm
Remove-Item -Path $PayloadPath -Recurse -Force

Write-Host "✅ Đã tạo file $OutputName thành công!"
Write-Host "📁 Vị trí: $(Resolve-Path $OutputName)"
```

**Cách dùng:**

1. **Lưu script vào file `create-ipa.ps1`**
2. **Mở PowerShell:**
   ```powershell
   cd "D:\Test\pocketvision_app\download"  # Thay đổi đường dẫn
   .\create-ipa.ps1
   ```

---

## 📱 Sử dụng file IPA với Sideloadly

Sau khi có file `Runner.ipa`:

1. **Mở Sideloadly**
2. **Kéo thả file `Runner.ipa`** vào Sideloadly
   - Hoặc click **"Select IPA/APP"** và chọn `Runner.ipa`
3. **Nhập Apple ID** của bạn
4. **Click "Start"**
5. **Đợi cài đặt hoàn tất**

---

## ⚠️ Lưu ý quan trọng

### **Cấu trúc IPA phải đúng:**
```
Runner.ipa (file ZIP)
└── Payload/          ← Thư mục này BẮT BUỘC
    └── Runner.app/   ← App bundle bên trong
        └── (các file)
```

### **Không được:**
- ❌ Đặt `Runner.app` trực tiếp vào ZIP (không có thư mục Payload)
- ❌ Đổi tên thư mục `Payload` thành tên khác
- ❌ Nén cả thư mục chứa Payload (phải nén Payload trực tiếp)

### **Phải:**
- ✅ Tạo thư mục `Payload` (chữ P viết hoa)
- ✅ Đặt `Runner.app` vào trong `Payload`
- ✅ Nén thư mục `Payload` (không phải thư mục cha)
- ✅ Đổi đuôi `.zip` thành `.ipa`

---

## 🎯 Tóm tắt nhanh

1. **Tạo thư mục `Payload`**
2. **Copy `Runner.app` vào `Payload`**
3. **Nén `Payload` thành ZIP**
4. **Đổi đuôi `.zip` thành `.ipa`**
5. **Dùng file `.ipa` với Sideloadly**

---

## 🆘 Vẫn không được?

Nếu vẫn gặp lỗi:

1. **Kiểm tra cấu trúc:**
   - Mở file `.ipa` bằng WinRAR/7-Zip
   - Phải thấy: `Payload/Runner.app/`

2. **Thử dùng Runner.app trực tiếp:**
   - Một số phiên bản Sideloadly có thể nhận `.app` bundle
   - Thử kéo thả thư mục `Runner.app` vào Sideloadly

3. **Dùng 3uTools:**
   - 3uTools có thể nhận cả `.app` và `.ipa`
   - Thử cài bằng 3uTools

---

**Chúc bạn thành công! 🎉**





