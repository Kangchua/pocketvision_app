# Script de chuyen doi favicon.ico thanh app_icon.png 1024x1024
# Su dung .NET System.Drawing de convert ICO sang PNG

Add-Type -AssemblyName System.Drawing

$faviconPath = "favicon.ico"
$outputPath = "assets\icon\app_icon.png"

# Kiem tra file favicon.ico co ton tai khong
if (-not (Test-Path $faviconPath)) {
    Write-Host "Khong tim thay file favicon.ico" -ForegroundColor Red
    exit 1
}

# Tao thu muc assets/icon neu chua co
if (-not (Test-Path "assets\icon")) {
    New-Item -ItemType Directory -Path "assets\icon" -Force | Out-Null
    Write-Host "Da tao thu muc assets/icon" -ForegroundColor Green
}

try {
    # Load icon tu file ICO
    $icon = [System.Drawing.Icon]::ExtractAssociatedIcon((Resolve-Path $faviconPath).Path)
    
    # Tao bitmap 1024x1024
    $bitmap = New-Object System.Drawing.Bitmap(1024, 1024)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    
    # Set high quality rendering
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    
    # Ve icon len bitmap voi kich thuoc lon nhat co the
    $graphics.Clear([System.Drawing.Color]::Transparent)
    # Convert icon to bitmap va scale len 1024x1024
    $iconBitmap = $icon.ToBitmap()
    $graphics.DrawImage($iconBitmap, 0, 0, 1024, 1024)
    $iconBitmap.Dispose()
    
    # Luu thanh PNG
    $bitmap.Save((Resolve-Path "assets\icon").Path + "\app_icon.png", [System.Drawing.Imaging.ImageFormat]::Png)
    
    # Cleanup
    $graphics.Dispose()
    $bitmap.Dispose()
    $icon.Dispose()
    
    Write-Host "Da chuyen doi favicon.ico thanh assets/icon/app_icon.png (1024x1024)" -ForegroundColor Green
    Write-Host "Bay gio chay: flutter pub run flutter_launcher_icons" -ForegroundColor Yellow
} catch {
    Write-Host "Loi khi chuyen doi: $_" -ForegroundColor Red
    Write-Host "Thu cach khac: Su dung cong cu online de convert ICO sang PNG 1024x1024" -ForegroundColor Yellow
    exit 1
}
