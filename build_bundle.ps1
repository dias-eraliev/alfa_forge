# Build script for Alfa Forge Android App Bundle
# This script sets required environment variables and builds the release AAB

Write-Host "Building Alfa Forge App Bundle..." -ForegroundColor Cyan

# Set NDK path
$env:ANDROID_NDK_HOME = "C:\Android\ndk\27.0.12077973"

# Build the app bundle
flutter build appbundle --release

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✓ Build successful!" -ForegroundColor Green
    Write-Host "App bundle location: build\app\outputs\bundle\release\app-release.aab" -ForegroundColor Yellow
} else {
    Write-Host "`n✗ Build failed!" -ForegroundColor Red
}
