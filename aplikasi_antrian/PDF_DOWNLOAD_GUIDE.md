# ✅ PDF Queue Ticket System - Setup Complete!

**Sistem untuk generate & download PDF nomor antrian dari aplikasi Flutter ke Windows.**

---

## 📋 Workflow Summary

### Step 1: Generate PDF di Aplikasi (Emulator)
```
Home → Select Payment → Enter NIK/BPJS → Validate → 
Queue Success Screen → Tap "Print/Export" → PDF Generated ✓
```

✅ **Status**: Working! PDF generated otomatis ke emulator storage

### Step 2: Download PDF ke Windows
**Easy Way - Run Script:**

**Option A (Recommended - Simple):**
```bash
# Folder: aplikasi_antrian\
double-click: pull_pdf_simple.bat
```
- Pull PDFs from emulator
- Copy to `queue_pdfs/` folder
- Copy to Windows `Downloads/`
- Auto-open `queue_pdfs` folder

**Option B (Advanced - PowerShell):**
```powershell
.\pull_pdf.ps1
```

---

## 📁 PDF Locations

After running pull script, PDFs saved in 2 places:

1. **Project Folder:**
   ```
   aplikasi_antrian/queue_pdfs/
   ```
   → Easy to version control, backup, share with team

2. **Windows Downloads:**
   ```
   C:\Users\[YourUsername]\Downloads\
   ```
   → Standard location, accessible from anywhere

---

## 📊 Folder Structure

```
aplikasi_antrian/
├── queue_pdfs/
│   ├── Antrian_N101_1777347601794.pdf
│   ├── Antrian_N101_1777347800947.pdf
│   ├── Antrian_N101_1777391329309.pdf
│   ├── ... (more PDFs)
│   └── README.md
├── pull_pdf_simple.bat       ← Use this!
├── pull_pdf.ps1              ← Or this
├── pull_pdf.bat
├── lib/
├── backend/
└── pubspec.yaml
```

---

## 🚀 Quick Start Guide

### Test Now:
1. ✅ Backend running: `http://localhost:8081` (check logs in terminal)
2. ✅ Flutter app running in emulator
3. ✅ Database ready with test data

### Generate Your First PDF:
1. Open Flutter app in emulator
2. Input test data:
   - **NIK:** `1203010101010001`
   - **BPJS:** `0001234567890`
3. Tap "Print/Export Nomor Antrian"
4. Should see success message ✓

### Download PDF:
```bash
# Run in CMD/PowerShell in project root
pull_pdf_simple.bat
```

Output:
```
[*] Pulling PDF files from emulator...
[+] Pulling to: D:\...\queue_pdfs
[+] Copying to: C:\Users\...\Downloads

[SUCCESS] PDFs saved to:
  1. D:\...\queue_pdfs
  2. C:\Users\...\Downloads
```

---

## 📝 Naming Convention

**Format:** `Antrian_[Code]_[Timestamp].pdf`

Examples:
- `Antrian_N101_1777453438364.pdf` ← Queue number
- `Antrian_120620260101_1704074401000.pdf` ← Queue code (if used)

**Timestamp:** Milliseconds since epoch (prevents overwrites)

---

## 🐛 Troubleshooting

### Issue: "PDF not found"
**Solution:**
1. Verify emulator is running: `flutter devices`
2. Generate PDF in app first (tap Export button)
3. Check logs in Flutter terminal
4. Try again

### Issue: ADB errors
**Solution:**
1. Install Android SDK Platform Tools
2. Add to PATH: `C:\Users\[username]\AppData\Local\Android\Sdk\platform-tools`
3. Restart terminal

### Issue: "Pull failed"
**Solution:**
1. Make sure Flutter app is still running (`flutter run`)
2. PDFs may be in app cache - regenerate one
3. Try: `adb pull /storage/emulated/0/Android/data/com.example.aplikasi_antrian/files/Download/ .`

---

## 💾 Manual Download (if scripts fail)

```bash
# Pull all PDFs manually
adb pull /storage/emulated/0/Android/data/com.example.aplikasi_antrian/files/Download/Antrian_*.pdf .

# Or single file
adb pull /storage/emulated/0/Android/data/com.example.aplikasi_antrian/files/Download/Antrian_N101_1777453438364.pdf .
```

---

## 📱 Test Data Available

```
Patient 1: Miranti R. Siregar
  - NIK: 1203010101010001
  - BPJS: 0001234567890
  - Queue: N101

Patient 2: Bintang H. Simanjuntak
  - NIK: 1203010202020002
  - BPJS: 0009876543210
  - Queue: N102

Patient 3: Roni Tua Sinaga
  - NIK: 1203010303030003
  - BPJS: 0001112223334
  - Queue: N103

Queue Codes:
  - 120620260101
  - 120620260102
  - 120620260103
```

---

## ✅ Verification Checklist

- [x] Backend API running (port 8081)
- [x] PostgreSQL database ready
- [x] Flutter app running in emulator
- [x] PDF generation working
- [x] queue_pdfs folder exists
- [x] Pull scripts created
- [x] PDFs downloadable to Windows

---

## 🎯 Next Steps

1. **Generate more test PDFs** - Try different patients/queue codes
2. **Test printing** - If printer available, app auto-detects
3. **Archive PDFs** - Move old PDFs to separate folder
4. **Production setup** - Configure for real devices/printers

---

**Status:** ✅ **System Ready for Use**

Last Updated: April 29, 2026
