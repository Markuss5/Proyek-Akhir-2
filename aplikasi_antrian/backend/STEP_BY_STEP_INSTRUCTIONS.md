# 📋 STEP-BY-STEP INSTRUCTION

## TUJUAN AKHIR
Membuat aplikasi Flutter bisa terkoneksi ke database PostgreSQL via API Golang, sehingga NIK dan BPJS yang diinput bisa terdeteksi.

---

# 🚀 EXECUTION PLAN (6 Steps)

## ✅ STEP 1: Jalankan Database (PostgreSQL via Docker)

**PERINTAH:**
```bash
cd backend
docker-compose up -d
```

**GUNA:**
- Menjalankan PostgreSQL database di background
- PostgreSQL dijalankan via Docker (container)

**APA YANG TERJADI:**
- 2 container akan start: `antrian_postgres` + `antrian_pgadmin`
- PostgreSQL listen di port 5432
- PgAdmin (UI untuk database) listen di port 5050

**WAKTU TUNGGU:**
⏱️ ~10-15 detik sampai PostgreSQL fully ready

**LIHAT STATUS:**
```bash
docker-compose ps
```

**EXPECTED OUTPUT:**
```
NAME                STATUS
antrian_postgres    Up (healthy)
antrian_pgadmin     Up
```

---

## ✅ STEP 2: Tunggu Database Ready (PENTING!)

**PERINTAH:**
```bash
timeout /t 15
```

atau di PowerShell:
```powershell
Start-Sleep -Seconds 15
```

**GUNA:**
- Memberi waktu PostgreSQL untuk fully initialize
- Jika terlalu cepat ke step 3, bisa connection error

**WAKTU:**
⏱️ 15 detik (tidak bisa dilewat!)

---

## ✅ STEP 3: Validasi & Setup Database (PENTING!)

**PERINTAH:**
```bash
go run ./cmd/database-util -validate
```

**GUNA:**
- Mengecek apakah database sudah ter-seed dengan data
- Menunjukkan semua NIK, BPJS, dan pasien yang ada

**EXPECTED OUTPUT:**
```
[DATABASE] Validating database integrity...
[DATABASE] Found 3 patients
[DATABASE] Found 3 queue codes
[PATIENT] ID: PT-0001 | NIK: 1206202612340001 | BPJS: 0001234567890 | Name: Miranti R. Siregar | Queue: N101
[PATIENT] ID: PT-0002 | NIK: 1206202612340002 | BPJS: 0009876543210 | Name: Bintang H. Simanjuntak | Queue: N102
[PATIENT] ID: PT-0003 | NIK: 1206202612340003 | BPJS: 0001112223334 | Name: Roni Tua Sinaga | Queue: N103
```

**APA JIKA OUTPUT BERBEDA?**

| Output | Masalah | Solusi |
|--------|---------|--------|
| `Found 0 patients` | Database kosong | Jalankan step 3.1 di bawah |
| Error: `connection refused` | Database tidak running | Ulangi step 1 & 2 |
| Error: `duplicate key value` | Ada duplikat data | Jalankan step 3.1 di bawah |

### **STEP 3.1: JIKA DATABASE KOSONG/ERROR → RESET**

**PERINTAH:**
```bash
go run ./cmd/database-util -reset
```

**GUNA:**
- Menghapus semua table lama
- Buat table baru dari scratch
- Insert 3 pasien dengan NIK & BPJS yang valid

**EXPECTED OUTPUT:**
```
[DATABASE] All tables dropped successfully
[DATABASE] Tables recreated successfully
[DATABASE] Fresh seed data inserted successfully
✅ Database reset completed successfully!
```

**KEMUDIAN: Jalankan validasi lagi**
```bash
go run ./cmd/database-util -validate
```

Harus terlihat 3 patients seperti di atas.

---

## ✅ STEP 4: Jalankan Backend API (Golang)

**PERINTAH (di Terminal BARU):**
```bash
cd backend
go run ./cmd/server
```

**GUNA:**
- Menjalankan API server Golang
- API akan listen di port 8081
- API akan handle validasi NIK, BPJS, Queue Code
- API akan connect ke PostgreSQL untuk query data

**EXPECTED OUTPUT:**
```
API server running on :8081
Health check: http://localhost:8081/health
```

**CATATAN:**
- Terminal ini HARUS tetap berjalan (jangan di-close)
- Jika perlu command lain, buka terminal baru

---

## ✅ STEP 5: TEST API (Verify Semuanya Jalan)

**PERINTAH (di Terminal BARU):**

### Test 5A: Health Check
```bash
curl http://localhost:8081/health
```

**EXPECTED:**
```
OK
```

---

### Test 5B: Test NIK Validation
```bash
curl -X POST http://localhost:8081/api/v1/validate/nik ^
  -H "Content-Type: application/json" ^
  -d "{\"nik\":\"1206202612340001\"}"
```

**EXPECTED:**
```json
{
  "isValid": true,
  "message": "NIK valid.",
  "patientId": "PT-0001",
  "queueNumber": "N101",
  "patientName": "Miranti R. Siregar"
}
```

---

### Test 5C: Test BPJS Validation
```bash
curl -X POST http://localhost:8081/api/v1/validate/bpjs-or-nik ^
  -H "Content-Type: application/json" ^
  -d "{\"input\":\"0001234567890\"}"
```

**EXPECTED:**
```json
{
  "isValid": true,
  "message": "BPJS valid.",
  "queueNumber": "N101",
  "patientName": "Miranti R. Siregar"
}
```

---

### Test 5D: Test Queue Code Verification
```bash
curl -X POST http://localhost:8081/api/v1/validate/queue-code ^
  -H "Content-Type: application/json" ^
  -d "{\"queueCode\":\"120620260101\"}"
```

**EXPECTED:**
```json
{
  "isValid": true,
  "message": "Queue code valid.",
  "data": {
    "queueCode": "120620260101",
    "queueNumber": "106",
    "patientName": "Miranti R. Siregar",
    "clinicName": "POLI BEDAH",
    "doctorName": "dr. Reynold Sianturi, Sp.B",
    "scheduleInfo": "Pelayanan 19/04/2026 09:00",
    "createdAt": "2026-04-19T08:41:00+07:00"
  }
}
```

**JIKA SEMUA TEST PASS → Backend sukses! ✅**

---

## ✅ STEP 6: Jalankan Flutter App

**PERINTAH (di Terminal BARU, dari root project):**
```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8081
```

**GUNA:**
- Menjalankan aplikasi Flutter
- `--dart-define=API_BASE_URL=...` memberi tahu Flutter di mana API server
- `10.0.2.2` adalah IP khusus untuk Android Emulator (akses host machine)
- Jika device fisik, ganti dengan IP komputer: `192.168.x.x:8081`

**EXPECTED:**
- App terbuka di emulator/device
- Home screen terlihat dengan 3 tombol (Konsultasi, Farmasi, Cetak)
- Semua berjalan normal

---

# 📝 COMPLETE COMMAND REFERENCE

Ini adalah urutan lengkap command yang harus dijalankan:

### **Terminal 1:**
```bash
cd backend
docker-compose up -d
timeout /t 15
go run ./cmd/database-util -validate
# Jika error, jalankan:
# go run ./cmd/database-util -reset
```

### **Terminal 2:**
```bash
cd backend
go run ./cmd/server
# Biarkan terminal ini tetap jalan
```

### **Terminal 3 (Testing - Optional):**
```bash
curl http://localhost:8081/health
curl -X POST http://localhost:8081/api/v1/validate/nik ^
  -H "Content-Type: application/json" ^
  -d "{\"nik\":\"1206202612340001\"}"
```

### **Terminal 4:**
```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8081
```

---

# 🎯 QUICK REFERENCE: Apa Setiap Step Lakukan?

| Step | Command | Fungsi | Output |
|------|---------|--------|--------|
| 1 | `docker-compose up -d` | Jalankan PostgreSQL | 2 containers running |
| 2 | `timeout /t 15` | Tunggu PostgreSQL siap | - |
| 3 | `go run ./cmd/database-util -validate` | Cek & setup database | Lihat 3 patients |
| 3.1 | `go run ./cmd/database-util -reset` | Reset jika error | Fresh data |
| 4 | `go run ./cmd/server` | Jalankan API | API running on :8081 |
| 5 | `curl http://localhost:8081/health` | Test API | OK |
| 6 | `flutter run ...` | Jalankan app | App berjalan di emulator |

---

# ✅ VERIFICATION CHECKLIST

Sebelum lanjut ke Flutter, pastikan semua ini sukses:

- [ ] Docker containers running (`docker-compose ps` shows 2 containers Up)
- [ ] Database validated (`go run ./cmd/database-util -validate` shows 3 patients)
- [ ] Backend running (`go run ./cmd/server` shows "API running")
- [ ] API responding (`curl http://localhost:8081/health` returns OK)
- [ ] NIK test pass (`curl ... /validate/nik` returns isValid: true)
- [ ] BPJS test pass (`curl ... /validate/bpjs-or-nik` returns isValid: true)
- [ ] Queue test pass (`curl ... /validate/queue-code` returns isValid: true)

**Jika semua ✅, baru jalankan Flutter!**

---

# 🆘 TROUBLESHOOTING

### **Problem: `docker-compose` command not found**
```
❌ docker-compose : The term 'docker-compose' is not recognized
```
**Solusi:**
- Install Docker Desktop dari https://www.docker.com/products/docker-desktop
- Restart PowerShell/CMD setelah install

---

### **Problem: Containers tidak running**
```
❌ docker-compose ps shows STATUS: Exit or Error
```
**Solusi:**
```bash
docker-compose down
docker-compose up -d
timeout /t 15
```

---

### **Problem: Database empty (0 patients)**
```
❌ go run ./cmd/database-util -validate shows: Found 0 patients
```
**Solusi:**
```bash
go run ./cmd/database-util -reset
```

---

### **Problem: API tidak respond**
```
❌ curl http://localhost:8081/health returns: connection refused
```
**Solusi:**
- Pastikan `go run ./cmd/server` berjalan di terminal lain
- Cek port 8081 tidak terpakai: `netstat -ano | findstr :8081`

---

### **Problem: Flutter connection error**
```
❌ App error: Cannot connect to API
```
**Solusi:**
1. Pastikan Backend API running
2. Pastikan API_BASE_URL benar:
   - Emulator: `http://10.0.2.2:8081`
   - Physical device: `http://[IP]:8081` (cek IP: `ipconfig`)

---

# 📞 JIKA MASIH ERROR

Hubungi dengan info ini:
1. Output dari: `docker-compose ps`
2. Output dari: `go run ./cmd/database-util -validate`
3. Output dari: `docker-compose logs postgres`
4. Tangkapan screenshot error di aplikasi

---

**🎉 Selamat! Jika semua step berhasil, aplikasi Anda sekarang siap digunakan!**

**Gunakan data test ini:**
```
NIK: 1206202612340001 atau 1206202612340002 atau 1206202612340003
BPJS: 0001234567890 atau 0009876543210 atau 0001112223334
Queue Codes: 120620260101 atau 120620260102 atau 120620260103
```
