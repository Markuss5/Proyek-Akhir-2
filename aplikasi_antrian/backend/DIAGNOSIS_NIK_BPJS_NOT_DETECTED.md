# DIAGNOSIS: NIK/BPJS Tidak Terdeteksi

## 🔴 MASALAH USER

NIK dan BPJS yang diberikan tidak masuk ke database, sehingga ketika input di aplikasi tidak terdeteksi.

---

## 🔍 DIAGNOSIS STEP-BY-STEP

### **STEP 1: Cek Docker Container Status**

```batch
docker-compose ps
```

**Hasil yang benar:**
```
NAME                  STATUS
antrian_postgres      Up (healthy)
antrian_pgadmin       Up
```

**Jika tidak running:**
```batch
cd backend
docker-compose up -d
timeout /t 15
```

---

### **STEP 2: Validasi Database Integrity**

```batch
go run ./cmd/database-util -validate
```

**Hasil yang benar:**
```
[DATABASE] Validating database integrity...
[DATABASE] Found 3 patients
[DATABASE] Found 3 queue codes
[PATIENT] ID: PT-0001 | NIK: 1206202612340001 | BPJS: 0001234567890 | Name: Miranti R. Siregar | Queue: N101
[PATIENT] ID: PT-0002 | NIK: 1206202612340002 | BPJS: 0009876543210 | Name: Bintang H. Simanjuntak | Queue: N102
[PATIENT] ID: PT-0003 | NIK: 1206202612340003 | BPJS: 0001112223334 | Name: Roni Tua Sinaga | Queue: N103
```

**Jika output berbeda atau error:**

| Output | Artinya | Solusi |
|--------|---------|--------|
| `[DATABASE] Found 0 patients` | Database kosong (data tidak di-seed) | `go run ./cmd/database-util -reset` |
| Error: `connection refused` | Database tidak running | `docker-compose up -d` |
| Error: `duplicate key value` | Ada duplikat data | `go run ./cmd/database-util -reset` |

---

### **STEP 3: Cek API Endpoint (Test dengan curl)**

```batch
REM Pastikan backend running di terminal lain: go run ./cmd/server
```

**Test 1: NIK Validation**
```batch
curl -X POST http://localhost:8081/api/v1/validate/nik ^
  -H "Content-Type: application/json" ^
  -d "{\"nik\":\"1206202612340001\"}"
```

**Response yang benar:**
```json
{
  "isValid": true,
  "message": "NIK valid.",
  "patientId": "PT-0001",
  "queueNumber": "N101",
  "patientName": "Miranti R. Siregar"
}
```

**Response jika tidak ada di database:**
```json
{
  "isValid": false,
  "message": "NIK tidak ditemukan pada database."
}
```

**Test 2: BPJS Validation**
```batch
curl -X POST http://localhost:8081/api/v1/validate/bpjs-or-nik ^
  -H "Content-Type: application/json" ^
  -d "{\"input\":\"0001234567890\"}"
```

**Response yang benar:**
```json
{
  "isValid": true,
  "message": "BPJS valid.",
  "queueNumber": "N101",
  "patientName": "Miranti R. Siregar"
}
```

---

## 🔧 SOLUSI BERDASARKAN DIAGNOSIS

### **Kasus 1: Database Kosong (0 patients)**

**Gejala:**
- `go run ./cmd/database-util -validate` output: `Found 0 patients`

**Penyebab:**
- Data belum pernah di-seed
- Seed process gagal sebelumnya

**Solusi:**
```batch
cd backend
go run ./cmd/database-util -reset
```

Output yang diharapkan:
```
[DATABASE] All tables dropped successfully
[DATABASE] Tables recreated successfully
[DATABASE] Fresh seed data inserted successfully
✅ Database reset completed successfully!
```

---

### **Kasus 2: Database Duplikat / Conflict**

**Gejala:**
- Error: `duplicate key value violates unique constraint "patients_nik_key"`
- Error: `duplicate key value violates unique constraint "patients_bpjs_number_key"`

**Penyebab:**
- Data sudah ada tapi ada duplikat entry
- Seeding fail di tengah jalan

**Solusi:**
```batch
cd backend
go run ./cmd/database-util -reset
```

---

### **Kasus 3: Connection Failed**

**Gejala:**
- Error: `connection refused`
- Error: `ping postgres: connection refused`

**Penyebab:**
- PostgreSQL container tidak running
- PostgreSQL belum fully initialized

**Solusi:**
```batch
cd backend

REM Stop dan clean
docker-compose down

REM Start fresh
docker-compose up -d

REM Tunggu 15 detik (important!)
timeout /t 15

REM Validasi
go run ./cmd/database-util -validate

REM Run backend
go run ./cmd/server
```

---

### **Kasus 4: API Endpoint Not Found**

**Gejala:**
- curl error: `connection refused` pada http://localhost:8081
- Backend tidak running

**Solusi:**
```batch
cd backend
go run ./cmd/server
```

Pastikan output:
```
API server running on :8081
Health check: http://localhost:8081/health
```

---

## 📋 RECOMMENDED FLOW (Start Fresh)

```batch
@echo off
cd backend

echo Step 1: Stop dan clean
docker-compose down

echo Step 2: Start containers
docker-compose up -d

echo Step 3: Wait for ready
timeout /t 15

echo Step 4: Reset database
go run ./cmd/database-util -reset

echo Step 5: Validate
go run ./cmd/database-util -validate

echo Step 6: Run backend
go run ./cmd/server
```

**Atau gunakan script yang sudah ada:**
```batch
run_backend.bat
```

---

## ✅ Verification Checklist

Setelah selesai, verifikasi dengan:

```batch
REM Terminal 1: (Backend sudah running)

REM Terminal 2: Test NIK
curl http://localhost:8081/api/v1/validate/nik -H "Content-Type: application/json" -d "{\"nik\":\"1206202612340001\"}"

REM Expected: isValid: true, message: "NIK valid.", patientName: "Miranti R. Siregar"

REM Terminal 2: Test BPJS
curl http://localhost:8081/api/v1/validate/bpjs-or-nik -H "Content-Type: application/json" -d "{\"input\":\"0001234567890\"}"

REM Expected: isValid: true, message: "BPJS valid.", patientName: "Miranti R. Siregar"

REM Terminal 2: Test Queue Code
curl http://localhost:8081/api/v1/validate/queue-code -H "Content-Type: application/json" -d "{\"queueCode\":\"120620260101\"}"

REM Expected: isValid: true, data with queue info
```

---

## 🆘 Jika Masih Error

1. **Cek Docker logs:**
   ```batch
   docker-compose logs postgres
   docker-compose logs pgadmin
   ```

2. **Cek PostgreSQL direct:**
   ```batch
   docker exec antrian_postgres psql -U postgres -d aplikasi_antrian -c "SELECT * FROM patients;"
   ```

3. **Lihat PgAdmin UI:**
   - Buka: http://localhost:5050
   - Login: admin@example.com / admin123
   - Check tables dan data manually

4. **Nuclear option (Bersihkan semua):**
   ```batch
   docker-compose down -v
   docker volume rm aplikasi_antrian_backend_postgres_data
   docker-compose up -d
   timeout /t 20
   go run ./cmd/database-util -reset
   ```

---

## 📞 Informasi Debugging

Collect these untuk troubleshoot lebih lanjut:
- Output dari `docker-compose ps`
- Output dari `go run ./cmd/database-util -validate`
- Output dari `docker-compose logs postgres`
- Screenshot dari error di aplikasi
- Screenshot dari response curl

---

**Status:** Database configuration sudah diperbaiki dan siap ditest!
