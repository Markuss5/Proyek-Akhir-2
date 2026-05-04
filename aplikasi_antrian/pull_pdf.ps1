# ============================================================
# PowerShell Script: Pull PDF dari Emulator ke Windows Folders
# ============================================================
# Jalankan: .\pull_pdf.ps1
# ============================================================

Write-Host ""
Write-Host "[*] Pulling latest PDF from emulator..." -ForegroundColor Cyan
Write-Host ""

# Check if adb is available
try {
    $adbTest = adb devices 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "ADB tidak tersedia"
    }
} catch {
    Write-Host "[ERROR] ADB tidak ditemukan. Pastikan:" -ForegroundColor Red
    Write-Host "  1. Android SDK Platform Tools sudah terinstall"
    Write-Host "  2. ADB sudah di-add ke PATH environment variable"
    Write-Host "  3. Emulator sudah running"
    Write-Host ""
    pause
    exit 1
}

# Get the script's directory (project root)
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$queuePdfsFolder = Join-Path $projectRoot "queue_pdfs"
$downloadsFolder = [System.IO.Path]::Combine($env:USERPROFILE, "Downloads")

# Create folders if they don't exist
if (-not (Test-Path $queuePdfsFolder)) {
    New-Item -ItemType Directory -Path $queuePdfsFolder | Out-Null
    Write-Host "[+] Created folder: $queuePdfsFolder" -ForegroundColor Green
}

# Initialize storage path variable
$storageBasePath = ""

# Step 1: Get list of PDFs from emulator
Write-Host "[+] Scanning emulator for PDF files..." -ForegroundColor Cyan
$emulatorPdfs = @()
$storageBasePath = ""

try {
    # First try app-specific storage directory (correct location)
    $output = adb shell ls /storage/emulated/0/Android/data/com.example.aplikasi_antrian/files/Download/Antrian_*.pdf 2>$null
    if ($LASTEXITCODE -eq 0 -and $output) {
        $emulatorPdfs = $output -split "`n" | Where-Object { $_ -match "Antrian_" }
        $storageBasePath = "/storage/emulated/0/Android/data/com.example.aplikasi_antrian/files/Download"
    } else {
        # Fallback to standard Download folder
        $output = adb shell ls /sdcard/Download/Antrian_*.pdf 2>$null
        if ($LASTEXITCODE -eq 0 -and $output) {
            $emulatorPdfs = $output -split "`n" | Where-Object { $_ -match "Antrian_" }
            $storageBasePath = "/sdcard/Download"
        }
    }
} catch {
    Write-Host "[!] Could not list files from emulator" -ForegroundColor Yellow
}

if ($emulatorPdfs.Count -eq 0) {
    Write-Host "[ERROR] Tidak ada PDF ditemukan di emulator" -ForegroundColor Red
    Write-Host ""
    Write-Host "Pastikan:"
    Write-Host "  1. Aplikasi sudah berjalan dan print/export PDF"
    Write-Host "  2. Emulator sudah running (flutter run masih aktif)"
    Write-Host ""
    pause
    exit 1
}

Write-Host "[+] Found $($emulatorPdfs.Count) PDF file(s)" -ForegroundColor Green
Write-Host ""

# Step 2: Pull each PDF to both folders
$successCount = 0
$failCount = 0

foreach ($pdfFile in $emulatorPdfs) {
    $pdfFile = $pdfFile.Trim()
    if ([string]::IsNullOrWhiteSpace($pdfFile)) { continue }
    
    # Extract just the filename
    $fileName = Split-Path -Leaf $pdfFile
    Write-Host "[*] Pulling: $fileName" -ForegroundColor Yellow
    
    # Full path on emulator
    $fullEmulatorPath = "$storageBasePath/$fileName"
    
    # Pull to queue_pdfs folder
    adb pull $fullEmulatorPath "$queuePdfsFolder\$fileName" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "    [OK] Saved to: queue_pdfs\$fileName" -ForegroundColor Green
        $successCount++
    } else {
        Write-Host "    [FAIL] Could not pull" -ForegroundColor Red
        $failCount++
        continue
    }
    
    # Also copy to Windows Downloads
    if (Test-Path "$queuePdfsFolder\$fileName") {
        Copy-Item "$queuePdfsFolder\$fileName" "$downloadsFolder\$fileName" -Force
        Write-Host "    [OK] Also copied to: Downloads\$fileName" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "[SUMMARY] Success: $successCount, Failed: $failCount" -ForegroundColor Cyan
Write-Host ""

# Step 3: Open folders
if ($successCount -gt 0) {
    Write-Host "[+] Opening queue_pdfs folder..." -ForegroundColor Green
    Start-Process explorer.exe -ArgumentList $queuePdfsFolder
    
    Write-Host "[+] PDF juga tersimpan di: $downloadsFolder" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "[OK] Selesai! Tekan Enter untuk keluar..." -ForegroundColor Green
} else {
    Write-Host "[ERROR] Tidak berhasil pull PDF apapun" -ForegroundColor Red
}

pause
