# Database Configuration - Quick Start

## 🚀 SETUP CEPAT (5 menit)

### **Opsi 1: Menggunakan Batch Script (Recommended for Windows)**

```batch
cd backend

REM Terminal 1: Setup & Run Backend dengan semua otomatis
run_backend.bat

REM Terminal 2 (baru): Jalankan Flutter
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8081
```

### **Opsi 2: Manual Setup**

```bash
# Terminal 1: Start Database
cd backend
docker-compose up -d
timeout /t 15  # Tunggu PostgreSQL siap

# Validasi database
go run ./cmd/database-util -validate

# Run backend
go run ./cmd/server

# Terminal 2: Run Flutter
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8081
```

### **Opsi 3: Menggunakan PowerShell Scripts**

```powershell
cd backend

# Setup containers
./manage_db.ps1 start

# Validate database
./manage_db.ps1 validate

# Run backend
go run ./cmd/server
```

---

## 📋 DATA YANG VALID (Sudah di Database)

Gunakan **salah satu dari ini** untuk testing:

### **Pasien 1: Miranti**
- **NIK**: `1206202612340001`
- **BPJS**: `0001234567890`
- **Nama**: Miranti R. Siregar

### **Pasien 2: Bintang**
- **NIK**: `1206202612340002`
- **BPJS**: `0009876543210`
- **Nama**: Bintang H. Simanjuntak

### **Pasien 3: Roni**
- **NIK**: `1206202612340003`
- **BPJS**: `0001112223334`
- **Nama**: Roni Tua Sinaga

### **Queue Codes**
- `120620260101` (Miranti - Poli Bedah)
- `120620260102` (Bintang - Poli Umum)
- `120620260103` (Roni - Poli Penyakit Dalam)

---

## ❌ MASALAH & SOLUSI CEPAT

| Masalah | Solusi |
|---------|--------|
| **NIK tidak terdeteksi** | `go run ./cmd/database-util -validate` dan cek data exist |
| **Docker container error** | `docker-compose down && docker-compose up -d` |
| **Data duplikat / conflict** | `go run ./cmd/database-util -reset` (akan clear & reseed) |
| **PgAdmin tidak bisa akses** | Cek `http://localhost:5050` dan pastikan container running |
| **API tidak respond** | `curl http://localhost:8081/health` untuk test |

---

## 🔍 TEST API (curl)

```bash
# Test NIK
curl -X POST http://localhost:8081/api/v1/validate/nik \
  -H "Content-Type: application/json" \
  -d "{\"nik\":\"1206202612340001\"}"

# Test BPJS
curl -X POST http://localhost:8081/api/v1/validate/bpjs-or-nik \
  -H "Content-Type: application/json" \
  -d "{\"input\":\"0001234567890\"}"

# Test Queue Code
curl -X POST http://localhost:8081/api/v1/validate/queue-code \
  -H "Content-Type: application/json" \
  -d "{\"queueCode\":\"120620260101\"}"

# Health Check
curl http://localhost:8081/health
```

---

## 📂 File-File Baru

| File | Fungsi |
|------|--------|
| `DATABASE_SETUP.md` | Dokumentasi lengkap troubleshooting |
| `manage_db.bat` | Database manager (Windows batch) |
| `manage_db.ps1` | Database manager (PowerShell) |
| `run_backend.bat` | One-click backend setup & run |
| `internal/database/reset.go` | Database reset utility |
| `cmd/database-util/main.go` | CLI for database operations |

---

## ✅ Checklist Sebelum Testing

- [ ] Docker installed & running
- [ ] PostgreSQL container started (`docker-compose up -d`)
- [ ] Database validated (`go run ./cmd/database-util -validate` shows 3 patients)
- [ ] Backend running (`go run ./cmd/server`)
- [ ] API responding (`curl http://localhost:8081/health`)
- [ ] Seed data present (validate output shows NIK & BPJS)
- [ ] Flutter connection correct (`API_BASE_URL=http://10.0.2.2:8081`)

---

## 💡 Tips

1. **Always validate first**: `go run ./cmd/database-util -validate`
2. **When in doubt, reset**: `go run ./cmd/database-util -reset`
3. **Check logs**: `docker-compose logs postgres`
4. **Test API before Flutter**: Use curl to verify endpoints work
5. **Use batch script**: `run_backend.bat` handles everything automatically

---

**Untuk dokumentasi lengkap, lihat:** [DATABASE_SETUP.md](./DATABASE_SETUP.md)
