# Script push code lên GitHub
# Chạy: .\push-to-github.ps1

Write-Host "🚀 Đang push code lên GitHub..." -ForegroundColor Green

# Kiểm tra Git
Write-Host "`n📋 Kiểm tra Git status..." -ForegroundColor Yellow
git status

# Hỏi xác nhận
$confirm = Read-Host "`n❓ Bạn có muốn commit và push các thay đổi? (y/n)"
if ($confirm -ne "y" -and $confirm -ne "Y") {
    Write-Host "❌ Đã hủy." -ForegroundColor Red
    exit
}

# Thêm tất cả file
Write-Host "`n📦 Đang thêm file..." -ForegroundColor Yellow
git add .

# Commit
Write-Host "💾 Đang commit..." -ForegroundColor Yellow
$commitMessage = Read-Host "Nhập commit message (hoặc Enter để dùng message mặc định)"
if ([string]::IsNullOrWhiteSpace($commitMessage)) {
    $commitMessage = "Update: Add AI server integration and config updates"
}
git commit -m $commitMessage

# Push
Write-Host "`n📤 Đang push lên GitHub..." -ForegroundColor Yellow
git push origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ Push thành công!" -ForegroundColor Green
    Write-Host "`n📱 Bước tiếp theo:" -ForegroundColor Cyan
    Write-Host "1. Vào GitHub: https://github.com/Kangchua/pocketvision_app" -ForegroundColor White
    Write-Host "2. Vào tab Actions để xem build iOS" -ForegroundColor White
    Write-Host "3. Hoặc dùng Codemagic/AppCircle để build nhanh hơn" -ForegroundColor White
} else {
    Write-Host "`n❌ Push thất bại. Kiểm tra lại authentication." -ForegroundColor Red
    Write-Host "💡 Có thể cần Personal Access Token" -ForegroundColor Yellow
}

