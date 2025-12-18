# Script tạo IPA từ Runner.app
# Cách dùng: .\create-ipa.ps1

param(
    [string]$AppPath = "Runner.app",
    [string]$OutputName = "Runner.ipa"
)

Write-Host "📦 Đang tạo file IPA..." -ForegroundColor Cyan

# Kiểm tra Runner.app có tồn tại không
if (-not (Test-Path $AppPath)) {
    Write-Host "❌ Không tìm thấy $AppPath" -ForegroundColor Red
    Write-Host "💡 Hãy đảm bảo bạn đang ở đúng thư mục chứa Runner.app" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "📁 Thư mục hiện tại: $(Get-Location)" -ForegroundColor Gray
    Write-Host "📋 Các file/thư mục có sẵn:" -ForegroundColor Gray
    Get-ChildItem | Select-Object Name, Mode | Format-Table
    exit 1
}

# Tạo thư mục Payload
$PayloadPath = "Payload"
if (Test-Path $PayloadPath) {
    Write-Host "🗑️  Xóa thư mục Payload cũ..." -ForegroundColor Yellow
    Remove-Item -Path $PayloadPath -Recurse -Force
}
Write-Host "📁 Tạo thư mục Payload..." -ForegroundColor Green
New-Item -ItemType Directory -Path $PayloadPath -Force | Out-Null

# Copy Runner.app vào Payload
Write-Host "📋 Đang copy $AppPath vào Payload..." -ForegroundColor Green
Copy-Item -Path $AppPath -Destination "$PayloadPath\Runner.app" -Recurse

# Tạo file ZIP
Write-Host "🗜️  Đang tạo file ZIP..." -ForegroundColor Green
$ZipPath = "$OutputName.zip"
if (Test-Path $ZipPath) {
    Remove-Item -Path $ZipPath -Force
}
Compress-Archive -Path $PayloadPath -DestinationPath $ZipPath -Force

# Đổi đuôi thành .ipa
Write-Host "🔄 Đang đổi đuôi thành .ipa..." -ForegroundColor Green
if (Test-Path $OutputName) {
    Remove-Item -Path $OutputName -Force
}
Rename-Item -Path $ZipPath -NewName $OutputName

# Xóa thư mục Payload tạm
Write-Host "🧹 Đang dọn dẹp..." -ForegroundColor Green
Remove-Item -Path $PayloadPath -Recurse -Force

Write-Host ""
Write-Host "✅ Đã tạo file $OutputName thành công!" -ForegroundColor Green
Write-Host "📁 Vị trí: $(Resolve-Path $OutputName)" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 Bây giờ bạn có thể dùng file này với Sideloadly!" -ForegroundColor Yellow



