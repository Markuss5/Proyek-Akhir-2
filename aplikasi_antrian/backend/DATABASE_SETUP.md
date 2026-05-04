# Database Setup & Troubleshooting Guide

## Status Terkini (Updated: April 29, 2026)

- **Backend Database Connection**: ✅ Working
- **Seed Data**: ✅ 3 pasien dengan NIK dan BPJS valid
- **Migration**: ✅ Automatic on startup
- **Docker Setup**: Via docker-compose.yml

---

## NIK & BPJS yang Valid (Sudah di Database)

```
PASIEN 1:
  ID        : PT-0001
  NIK       : 1206202612340001
  BPJS      : 0001234567890
  Nama      : Miranti R. Siregar
  Queue     : N101

PASIEN 2:
  ID        : PT-0002
  NIK       : 1206202612340002
  BPJS      : 0009876543210
  Nama      : Bintang H. Simanjuntak
  Queue     : N102

PASIEN 3:
  ID        : PT-0003
  NIK       : 1206202612340003
  BPJS      : 0001112223334
  Nama      : Roni Tua Sinaga
  Queue     : N103
```

---

## Troubleshooting Checklist

### ❌ Masalah 1: NIK/BPJS Tidak Terdeteksi

**Penyebab Umum:**
- [ ] PostgreSQL container tidak running
- [ ] Database tidak ter-seed dengan data
- [ ] Ada duplikat data yang menyebabkan constraint error
- [ ] API tidak terhubung ke database yang benar

**Solusi:**

1. **Pastikan Docker Running**
   ```bash
   cd backend
   docker-compose up -d
   ```

2. **Reset Database** (jika ada duplikat atau corrupt data)
   ```bash
   go run ./cmd/database-util -reset
   ```

3. **Validasi Database**
   ```bash
   go run ./cmd/database-util -validate
   ```

   Output yang benar:
   ```
   [DATABASE] Found 3 patients
   [PATIENT] ID: PT-0001 | NIK: 1206202612340001 | BPJS: 0001234567890 | ...
   [PATIENT] ID: PT-0002 | NIK: 1206202612340002 | BPJS: 0009876543210 | ...
   [PATIENT] ID: PT-0003 | NIK: 1206202612340003 | BPJS: 0001112223334 | ...
   ```

4. **Test API Endpoint**
   ```bash
   # Terminal: Run backend
   go run ./cmd/server

   # Terminal baru: Test API
   curl -X POST http://localhost:8081/api/v1/validate/nik \
     -H "Content-Type: application/json" \
     -d '{"nik":"1206202612340001"}'

   # Expected response:
   # {"isValid":true,"message":"NIK valid.","patientId":"PT-0001","queueNumber":"N101","patientName":"Miranti R. Siregar"}
   ```

---

### ❌ Masalah 2: Database Connection Error

**Gejala:**
- API error: "database init failed"
- Error: "ping postgres: connection refused"

**Solusi:**

1. **Cek Docker Container Status**
   ```bash
   docker-compose ps
   ```

   Output yang benar:
   ```
   NAME                    STATUS
   antrian_postgres        Up
   antrian_pgadmin         Up
   ```

2. **Jika container tidak running:**
   ```bash
   cd backend
   docker-compose down    # Stop semua
   docker-compose up -d   # Start fresh
   docker-compose logs -f postgres  # Monitor logs
   ```

3. **Tunggu ~10 detik** hingga PostgreSQL fully initialized

4. **Cek database file** (ada volume persistence)
   ```bash
   docker volume ls | grep postgres_data
   ```

---

### ❌ Masalah 3: Data Duplikat / Constraint Error

**Gejala:**
- Error: "duplicate key value violates unique constraint"
- Seeding mungkin fail di tengah jalan

**Solusi:**

1. **Reset database dengan clean slate**
   ```bash
   go run ./cmd/database-util -reset
   ```

   Log output yang benar:
   ```
   [DATABASE] All tables dropped successfully
   [DATABASE] Tables recreated successfully
   [DATABASE] Fresh seed data inserted successfully
   ✅ Database reset completed successfully!
   ```

2. **Atau manual cleanup via PgAdmin**
   - Buka: http://localhost:5050
   - Login: admin@example.com / admin123
   - Drop existing tables
   - Run backend API sekali (akan auto-migrate)

---

### ❌ Masalah 4: PgAdmin tidak accessible

**Gejala:**
- Tidak bisa akses http://localhost:5050
- Network timeout

**Solusi:**

1. **Pastikan container running**
   ```bash
   docker-compose ps
   ```

2. **Restart PgAdmin**
   ```bash
   docker-compose restart pgadmin
   ```

3. **Cek port 5050 tidak terpakai**
   ```bash
   netstat -ano | findstr :5050
   ```

---

## Setup Flow yang Benar

### **Step 1: Start Database**
```bash
cd backend
docker-compose up -d
docker-compose logs -f  # Monitor sampai healthy
```

### **Step 2: Validate/Reset Data**
```bash
go run ./cmd/database-util -validate

# Jika ada masalah, reset:
go run ./cmd/database-util -reset
```

### **Step 3: Run Backend**
```bash
go run ./cmd/server
```

Output yang benar:
```
API server running on :8081
Health check: http://localhost:8081/health
[DATABASE] Available data in database:
[PATIENT] ID: PT-0001 | NIK: 1206202612340001 | BPJS: 0001234567890 | ...
```

### **Step 4: Run Flutter**
```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8081
```

---

## Testing Endpoints

### Test NIK Validation
```bash
curl -X POST http://localhost:8081/api/v1/validate/nik \
  -H "Content-Type: application/json" \
  -d '{"nik":"1206202612340001"}'

# Response:
# {"isValid":true,"message":"NIK valid.","patientId":"PT-0001","queueNumber":"N101","patientName":"Miranti R. Siregar"}
```

### Test BPJS Validation
```bash
curl -X POST http://localhost:8081/api/v1/validate/bpjs-or-nik \
  -H "Content-Type: application/json" \
  -d '{"input":"0001234567890"}'

# Response:
# {"isValid":true,"message":"BPJS valid.","queueNumber":"N101","patientName":"Miranti R. Siregar"}
```

### Test Invalid NIK
```bash
curl -X POST http://localhost:8081/api/v1/validate/nik \
  -H "Content-Type: application/json" \
  -d '{"nik":"9999999999999999"}'

# Response:
# {"isValid":false,"message":"NIK tidak ditemukan pada database."}
```

---

## Environment Variables

**File:** `.env` atau docker-compose.yml

```env
# Backend
API_ADDR=:8081
DATABASE_URL=postgres://postgres:postgres@localhost:5432/aplikasi_antrian?sslmode=disable

# PostgreSQL (di docker-compose)
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=aplikasi_antrian

# PgAdmin (di docker-compose)
PGADMIN_DEFAULT_EMAIL=admin@example.com
PGADMIN_DEFAULT_PASSWORD=admin123
```

---

## Database Architecture

### Tables:

**1. patients**
```sql
id              TEXT PRIMARY KEY
nik             VARCHAR(16) NOT NULL UNIQUE
bpjs_number     VARCHAR(13) NOT NULL UNIQUE
name            TEXT NOT NULL
queue_number    TEXT NOT NULL
```

**2. queue_codes**
```sql
queue_code      VARCHAR(12) PRIMARY KEY
queue_number    TEXT NOT NULL
patient_id      TEXT NOT KEY REFERENCES patients(id)
clinic_name     TEXT NOT NULL
doctor_name     TEXT NOT NULL
schedule_info   TEXT NOT NULL
created_at      TIMESTAMPTZ NOT NULL
```

**3. pharmacy_queues**
```sql
id              TEXT PRIMARY KEY
pharmacy_queue_code VARCHAR(12) NOT NULL
queue_number    TEXT NOT NULL
patient_id      TEXT NOT KEY REFERENCES patients(id)
clinic_name     TEXT
doctor_name     TEXT
schedule_info   TEXT
created_at      TIMESTAMPTZ NOT NULL
```

---

## Common Commands Reference

| Task | Command |
|------|---------|
| **Start containers** | `docker-compose up -d` |
| **Stop containers** | `docker-compose down` |
| **View logs** | `docker-compose logs -f` |
| **Reset database** | `go run ./cmd/database-util -reset` |
| **Validate database** | `go run ./cmd/database-util -validate` |
| **Run backend** | `go run ./cmd/server` |
| **PgAdmin UI** | http://localhost:5050 |
| **Health check** | http://localhost:8081/health |

---

## Quick Checklist untuk Debug

- [ ] Docker containers running (`docker-compose ps`)
- [ ] PostgreSQL accessible (`curl http://localhost:5432`)
- [ ] Database created (`go run ./cmd/database-util -validate`)
- [ ] Backend running (`go run ./cmd/server`)
- [ ] API responsive (`curl http://localhost:8081/health`)
- [ ] Seed data present (`go run ./cmd/database-util -validate` shows 3 patients)
- [ ] NIK/BPJS in database matches aplikasi input
- [ ] Flutter connected to correct API_BASE_URL

---

## Support Tips

1. **Always check logs first**
   ```bash
   docker-compose logs postgres
   docker-compose logs pgadmin
   ```

2. **Reset adalah teman terbaik mu**
   ```bash
   go run ./cmd/database-util -reset
   ```

3. **Validate sebelum menuduh API**
   ```bash
   go run ./cmd/database-util -validate
   ```

4. **Test API dulu sebelum Flutter**
   ```bash
   curl -X POST http://localhost:8081/api/v1/validate/nik ...
   ```

---

**Last Updated:** April 29, 2026  
**Maintainer:** Database Configuration Team
