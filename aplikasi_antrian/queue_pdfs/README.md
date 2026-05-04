# Queue PDF Folder

**Lokasi tempat menyimpan PDF nomor antrian yang sudah digenerate dari aplikasi.**

## Workflow

### Step 1: Generate PDF di Aplikasi
1. Buka aplikasi Flutter di emulator
2. Input NIK atau BPJS nomor pasien
3. Validasi berhasil → Masuk ke "Queue Verification Success" screen
4. Tap tombol **"Print / Export Nomor Antrian"**
5. PDF akan disimpan ke emulator internal storage

### Step 2: Pull PDF ke Windows
Pilih salah satu cara:

#### **Cara A: PowerShell (Recommended - Lebih Detail)**
```powershell
# Di PowerShell (Windows Terminal / PowerShell IDE)
# Buka di root project aplikasi
.\pull_pdf.ps1
```
- Menampilkan list PDFs yang ditemukan
- Auto-copy ke folder ini (queue_pdfs)
- Auto-copy ke Windows Downloads
- Buka folder otomatis

#### **Cara B: Command Prompt (CMD)
```cmd
# Di Command Prompt
pull_pdf.bat
```
- Copy ke folder ini
- Copy ke Windows Downloads
- Buka folder otomatis

#### **Cara C: Manual ADB
```bash
adb pull /sdcard/Download/Antrian_*.pdf ./
```

## File Structure

```
queue_pdfs/
├── README.md (file ini)
├── Antrian_N101_1234567890.pdf
├── Antrian_120620260101_1234567891.pdf
└── ... (semua PDF yang berhasil didownload)
```

## Naming Convention

**Format nama file:** `Antrian_[QueueCode_or_Number]_[Timestamp].pdf`

Contoh:
- `Antrian_N101_1704074400000.pdf` → Queue number N101
- `Antrian_120620260101_1704074401000.pdf` → Queue code

## Troubleshooting

### PDF tidak muncul saat jalankan pull_pdf
1. ✓ Pastikan emulator sudah running: `flutter run` masih aktif
2. ✓ Pastikan sudah generate PDF di app (tap "Print / Export")
3. ✓ Cek di emulator: Settings → Apps → aplikasi_antrian → Storage

### ADB Error
```
[ERROR] ADB tidak ditemukan
```
**Solusi:**
- Install Android SDK Platform Tools
- Add ke PATH: `C:\Users\[username]\AppData\Local\Android\Sdk\platform-tools`
- Restart terminal

### Emulator tidak terdeteksi
```bash
# Cek device yang terhubung
flutter devices

# Atau dengan adb
adb devices
```

## Notes
- Setiap kali generate PDF, timestamp otomatis ditambah untuk hindari overwrite
- PDF bisa dicetak langsung atau disimpan untuk referensi
- Windows Downloads folder juga mendapat copy otomatis

---
**Last Updated:** April 29, 2026
