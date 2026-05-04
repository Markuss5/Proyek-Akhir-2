# DATABASE FIX SUMMARY - April 29, 2026

## Problem Statement

User melaporkan bahwa beberapa NIK dan nomor BPJS yang seharusnya ada di database tidak terdeteksi ketika diinput di aplikasi Flutter.

**Kemungkinan Penyebab:**
- Docker container tidak running
- Database tidak ter-seed dengan proper
- Ada duplikat data yang menyebabkan constraint error
- Migration gagal di tengah jalan
- PgAdmin tidak aktif

---

## Solution Implemented

### 1. **Enhanced Database Reset Utility**
- **File:** `backend/internal/database/reset.go`
- **Fungsi:** 
  - Drop existing tables dengan proper cascade
  - Recreate tables fresh
  - Re-seed data
  - Validate database integrity
  - Show all available data in database

### 2. **Database CLI Utility**
- **File:** `backend/cmd/database-util/main.go`
- **Commands:**
  - `go run ./cmd/database-util -reset` → Reset database completely
  - `go run ./cmd/database-util -validate` → Check database integrity

### 3. **Windows Batch Scripts**
- **File:** `backend/run_backend.bat`
  - One-click setup & run backend
  - Automatic database validation & reset if needed
  
- **File:** `backend/manage_db.bat`
  - `manage_db.bat start` → Start containers
  - `manage_db.bat validate` → Validate database
  - `manage_db.bat reset` → Reset database
  - `manage_db.bat stop` → Stop containers

### 4. **PowerShell Script**
- **File:** `backend/manage_db.ps1`
  - PowerShell alternative for database management
  - Same commands as batch version

### 5. **Comprehensive Documentation**

#### **DATABASE_SETUP.md**
- Full troubleshooting guide
- All error codes & solutions
- Endpoint testing examples
- Environment variable reference
- Common commands reference

#### **DATABASE_QUICKSTART.md**
- Quick start in 5 minutes
- Valid test data reference
- Quick problem solutions
- Testing examples with curl

#### **DIAGNOSIS_NIK_BPJS_NOT_DETECTED.md**
- Step-by-step diagnosis process
- Test each layer (container, DB, API)
- Solution for each diagnosis result
- Verification checklist

### 6. **Improved Database Seeding**
- **File:** `backend/internal/database/postgres.go`
- **Changes:**
  - Added transaction handling for atomic operations
  - Check if data exists before seeding (prevent duplicates)
  - Better error handling
  - Proper rollback on failure

---

## 📋 Valid Test Data (Sudah di Database)

```
PASIEN 1:
  NIK: 1206202612340001
  BPJS: 0001234567890
  Nama: Miranti R. Siregar
  Queue: N101

PASIEN 2:
  NIK: 1206202612340002
  BPJS: 0009876543210
  Nama: Bintang H. Simanjuntak
  Queue: N102

PASIEN 3:
  NIK: 1206202612340003
  BPJS: 0001112223334
  Nama: Roni Tua Sinaga
  Queue: N103

QUEUE CODES:
  120620260101 (Miranti - Poli Bedah)
  120620260102 (Bintang - Poli Umum)
  120620260103 (Roni - Poli Penyakit Dalam)
```

---

## 🚀 Quick Setup Instructions

### **Option 1: Automatic (Recommended)**
```batch
cd backend
run_backend.bat
```
This will automatically:
1. Start Docker containers
2. Wait for PostgreSQL
3. Validate database (or reset if needed)
4. Run backend server

### **Option 2: Manual**
```batch
cd backend

REM Terminal 1:
docker-compose up -d
timeout /t 15
go run ./cmd/database-util -validate
go run ./cmd/server

REM Terminal 2:
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8081
```

### **Option 3: PowerShell**
```powershell
cd backend

# Setup
./manage_db.ps1 start
./manage_db.ps1 validate

# Run
go run ./cmd/server
```

---

## ✅ Verification Checklist

After setup, verify with:

```bash
# Test 1: Validate Database
go run ./cmd/database-util -validate
# Expected: Shows 3 patients with correct NIK/BPJS

# Test 2: Test NIK API
curl -X POST http://localhost:8081/api/v1/validate/nik \
  -H "Content-Type: application/json" \
  -d "{\"nik\":\"1206202612340001\"}"
# Expected: {"isValid":true,"message":"NIK valid.","patientName":"Miranti R. Siregar",...}

# Test 3: Test BPJS API
curl -X POST http://localhost:8081/api/v1/validate/bpjs-or-nik \
  -H "Content-Type: application/json" \
  -d "{\"input\":\"0001234567890\"}"
# Expected: {"isValid":true,"message":"BPJS valid.","patientName":"Miranti R. Siregar",...}

# Test 4: Flutter Input
# Input NIK: 1206202612340001
# Expected: "NIK valid" message + patient details
```

---

## 🔧 Common Fixes

| Problem | Command |
|---------|---------|
| NIK/BPJS not detected | `go run ./cmd/database-util -validate` |
| Data duplikat | `go run ./cmd/database-util -reset` |
| Container not running | `docker-compose up -d` |
| Connection error | Stop and restart: `docker-compose down && docker-compose up -d` |
| PgAdmin not accessible | Check port 5050 is free |

---

## 📂 Files Created/Modified

### New Files:
- `backend/internal/database/reset.go` - Database reset utility
- `backend/cmd/database-util/main.go` - CLI utility
- `backend/run_backend.bat` - One-click backend setup
- `backend/manage_db.bat` - Database manager (batch)
- `backend/manage_db.ps1` - Database manager (PowerShell)
- `backend/DATABASE_SETUP.md` - Full documentation
- `backend/DATABASE_QUICKSTART.md` - Quick start guide
- `backend/DIAGNOSIS_NIK_BPJS_NOT_DETECTED.md` - Diagnosis guide

### Modified Files:
- `backend/internal/database/postgres.go` - Improved seed logic with transactions

---

## 💡 Key Improvements

1. **Robustness**: Database reset now handles all edge cases
2. **Debugging**: `validate` command shows exactly what's in database
3. **User-Friendly**: Batch scripts make setup easy for Windows users
4. **Documentation**: 3 comprehensive guides for different use cases
5. **Error Recovery**: Automatic reset on first-time setup if needed
6. **Transaction Safety**: Seed data uses atomic transactions

---

## 🎯 Next Steps for User

1. **Run the setup:**
   ```batch
   cd backend
   run_backend.bat
   ```

2. **Verify database:**
   ```batch
   go run ./cmd/database-util -validate
   ```

3. **Test API endpoints** using curl

4. **Run Flutter** with correct API_BASE_URL

5. **Input test data** (NIK/BPJS from valid list above)

6. **Should work now!** ✅

---

## 📞 Support Resources

- Detailed troubleshooting: [DATABASE_SETUP.md](./DATABASE_SETUP.md)
- Quick reference: [DATABASE_QUICKSTART.md](./DATABASE_QUICKSTART.md)  
- Diagnosis steps: [DIAGNOSIS_NIK_BPJS_NOT_DETECTED.md](./DIAGNOSIS_NIK_BPJS_NOT_DETECTED.md)

---

**Status: ✅ READY FOR TESTING**

All database configuration issues should now be resolved. If problems persist, follow the step-by-step diagnosis guide.
