# 📋 QUICK COMMAND CARD (Cheat Sheet)

## COPY-PASTE COMMANDS

---

### **TERMINAL 1: Start Database**

```bash
cd backend
docker-compose up -d
timeout /t 15
go run ./cmd/database-util -validate
```

**If output shows `Found 0 patients`, run:**
```bash
go run ./cmd/database-util -reset
```

---

### **TERMINAL 2: Run Backend**

```bash
cd backend
go run ./cmd/server
```

**Wait for output:**
```
API server running on :8081
```

---

### **TERMINAL 3: Test API (Optional)**

```bash
# Test 1: Health Check
curl http://localhost:8081/health

# Test 2: NIK Validation
curl -X POST http://localhost:8081/api/v1/validate/nik -H "Content-Type: application/json" -d "{\"nik\":\"1206202612340001\"}"

# Test 3: BPJS Validation
curl -X POST http://localhost:8081/api/v1/validate/bpjs-or-nik -H "Content-Type: application/json" -d "{\"input\":\"0001234567890\"}"

# Test 4: Queue Code Verification
curl -X POST http://localhost:8081/api/v1/validate/queue-code -H "Content-Type: application/json" -d "{\"queueCode\":\"120620260101\"}"
```

---

### **TERMINAL 4: Run Flutter**

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8081
```

---

## 📊 WHAT EACH TERMINAL DOES

| Terminal | Command | Purpose | Keep Running? |
|----------|---------|---------|----------------|
| 1 | `docker-compose up -d` + validate | Setup database | No (background) |
| 2 | `go run ./cmd/server` | Run API backend | **YES** ⭐ |
| 3 | `curl ...` | Test API | No (testing only) |
| 4 | `flutter run ...` | Run mobile app | **YES** ⭐ |

---

## ✅ SUCCESS INDICATORS

| Step | Success = | Failure = |
|------|-----------|-----------|
| Step 1 | `docker-compose ps` shows both containers Up | Connection refused |
| Step 3 | Shows 3 patients with NIK & BPJS | Found 0 patients or error |
| Step 4 | `API server running on :8081` | Connection refused |
| Step 5 | curl returns JSON data | Connection refused |
| Step 6 | App opens in emulator | Cannot connect to API |

---

## 📋 TEST DATA (Use Any of These)

```
OPTION 1:
  NIK: 1206202612340001
  BPJS: 0001234567890
  Name: Miranti R. Siregar
  Queue Code: 120620260101

OPTION 2:
  NIK: 1206202612340002
  BPJS: 0009876543210
  Name: Bintang H. Simanjuntak
  Queue Code: 120620260102

OPTION 3:
  NIK: 1206202612340003
  BPJS: 0001112223334
  Name: Roni Tua Sinaga
  Queue Code: 120620260103
```

---

## 🆘 EMERGENCY COMMANDS

**Database error?**
```bash
go run ./cmd/database-util -reset
```

**Docker not responding?**
```bash
docker-compose down
docker-compose up -d
timeout /t 15
```

**Want to see what's in database?**
```bash
go run ./cmd/database-util -validate
```

**Want to check database directly?**
```
Open: http://localhost:5050
Email: admin@example.com
Password: admin123
```

---

## 🎯 MINIMUM WORKING SETUP

```bash
# Terminal 1
cd backend && docker-compose up -d && timeout /t 15 && go run ./cmd/database-util -validate

# Terminal 2
cd backend && go run ./cmd/server

# Terminal 3
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8081
```

**Beres! 🎉**

---

## 📝 NOTES

- **Terminal 2 & 4 MUST stay running** (don't close them)
- **Terminal 1 is one-time setup** (can close after validation)
- **If something fails, check** [STEP_BY_STEP_INSTRUCTIONS.md](./STEP_BY_STEP_INSTRUCTIONS.md)
- **Use Ctrl+C to stop any terminal**

---

**Last Updated: April 29, 2026**
