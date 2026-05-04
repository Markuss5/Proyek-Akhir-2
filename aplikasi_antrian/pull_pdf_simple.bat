@echo off
REM ============================================================
REM Simple script to pull PDFs from emulator
REM ============================================================

echo [*] Pulling PDF files from emulator...
echo.

set QUEUE_FOLDER=%CD%\queue_pdfs
set DOWNLOADS=%USERPROFILE%\Downloads

if not exist "%QUEUE_FOLDER%" mkdir "%QUEUE_FOLDER%"

echo [+] Pulling to: %QUEUE_FOLDER%
adb pull /storage/emulated/0/Android/data/com.example.aplikasi_antrian/files/Download/Antrian_*.pdf "%QUEUE_FOLDER%"

if exist "%QUEUE_FOLDER%\Antrian_*.pdf" (
    echo [+] Copying to: %DOWNLOADS%
    copy "%QUEUE_FOLDER%\Antrian_*.pdf" "%DOWNLOADS%" >nul
    
    echo.
    echo [SUCCESS] PDFs saved to:
    echo   1. %QUEUE_FOLDER%
    echo   2. %DOWNLOADS%
    echo.
    
    explorer "%QUEUE_FOLDER%"
) else (
    echo [ERROR] PDF not found. Make sure you generate PDFs in the app first.
)

pause
