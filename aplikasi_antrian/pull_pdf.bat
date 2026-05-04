@echo off
REM ============================================================
REM Auto-Pull PDF dari Emulator ke Queue Folder
REM ============================================================
REM Target: D:\Folder Semester 4\Pengembangan Aplikasi Mobile\Week 9\Praktikum\aplikasi_antrian\queue_pdfs
REM ============================================================

echo.
echo [*] Pulling latest PDF from emulator...
echo.

REM Check if adb is available
adb devices >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] ADB tidak ditemukan. Pastikan ADB sudah terinstall di PATH
    pause
    exit /b 1
)

REM Get current directory (project root)
set QUEUE_PDFS_FOLDER=%CD%\queue_pdfs

REM Create queue_pdfs folder if not exists
if not exist "%QUEUE_PDFS_FOLDER%" (
    mkdir "%QUEUE_PDFS_FOLDER%"
)

REM Pull latest PDF files from emulator to queue_pdfs
echo [+] Pulling PDFs from emulator ke queue_pdfs...
adb pull /storage/emulated/0/Android/data/com.example.aplikasi_antrian/files/Download/Antrian_*.pdf "%QUEUE_PDFS_FOLDER%\" >nul 2>&1

REM If that fails, try fallback location
if %errorlevel% neq 0 (
    adb pull /sdcard/Download/Antrian_*.pdf "%QUEUE_PDFS_FOLDER%\" >nul 2>&1
)

REM Check if pull was successful
if exist "%QUEUE_PDFS_FOLDER%\Antrian_*.pdf" (
    echo.
    echo [SUCCESS] PDF berhasil didownload:
    echo.
    echo 📁 Lokasi: %QUEUE_PDFS_FOLDER%\
    echo.
    echo Tekan Enter untuk membuka folder...
    pause
    
    REM Open queue_pdfs folder in Windows Explorer
    start "" "%QUEUE_PDFS_FOLDER%"
) else (
    echo.
    echo [ERROR] Gagal pull PDF dari emulator
    echo Pastikan:
    echo 1. Emulator sudah running
    echo 2. App sudah print dan create PDF
    echo 3. PDF ada di: /storage/emulated/0/Android/data/com.example.aplikasi_antrian/files/Download/
    echo.
    pause
    exit /b 1
)

