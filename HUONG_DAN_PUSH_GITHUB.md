# 📤 Hướng dẫn Push Code lên GitHub

## ✅ Bước 1: Đã hoàn thành
- ✅ Đã cấu hình Git user
- ✅ Đã commit code thành công

## 📋 Bước 2: Tạo GitHub Repository

1. **Đăng nhập GitHub:** https://github.com
2. **Tạo repository mới:**
   - Click nút **"+"** > **"New repository"**
   - Đặt tên: `pocketvision_app` (hoặc tên khác)
   - Chọn **Public** (để dùng GitHub Actions miễn phí)
   - **KHÔNG** tích "Initialize with README"
   - Click **"Create repository"**

3. **Copy URL repository:**
   - Sẽ có dạng: `https://github.com/username/pocketvision_app.git`

## 🚀 Bước 3: Push Code lên GitHub

Mở PowerShell trong thư mục `pocketvision_app` và chạy:

```powershell
# Thay 'username' và 'pocketvision_app' bằng thông tin của bạn
git remote add origin https://github.com/username/pocketvision_app.git

# Push code lên GitHub
git branch -M main
git push -u origin main
```

**Lưu ý:** 
- Nếu GitHub yêu cầu authentication, bạn có thể:
  - Sử dụng **Personal Access Token** (khuyến nghị)
  - Hoặc **GitHub CLI**: `gh auth login`

## 🔑 Tạo Personal Access Token (Nếu cần)

1. Vào GitHub > Settings > Developer settings > Personal access tokens > Tokens (classic)
2. Click **"Generate new token"**
3. Chọn quyền: **repo** (full control)
4. Copy token (chỉ hiện 1 lần!)
5. Khi push, dùng token thay vì password

## ✅ Bước 4: Kiểm tra

Sau khi push thành công:
1. Vào GitHub repository
2. Kiểm tra code đã được upload
3. Kiểm tra có file `.github/workflows/build-ios.yml`

## 🎯 Bước 5: Chạy Build iOS

1. Vào tab **Actions** trong GitHub repository
2. Chọn workflow **"Build iOS App"**
3. Click **"Run workflow"** > **"Run workflow"**
4. Đợi 5-10 phút để build xong
5. Download artifact từ phần **Artifacts**

---

**Chúc bạn thành công! 🎉**




