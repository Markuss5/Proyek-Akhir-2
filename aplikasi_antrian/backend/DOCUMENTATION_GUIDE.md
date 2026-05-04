# 📚 DOCUMENTATION GUIDE

Ini adalah guide lengkap untuk semua dokumentasi yang tersedia. Pilih sesuai kebutuhan Anda:

---

## 🚀 **JUST WANT TO RUN IT? START HERE:**

### **Option 1: Untuk User yang Ingin Copy-Paste Commands**
📄 **File:** [COMMAND_CHEAT_SHEET.md](./COMMAND_CHEAT_SHEET.md)
- ✅ Hanya commands, tidak ada penjelasan panjang
- ✅ Copy-paste langsung ke terminal
- ✅ Quick reference untuk survival
- ⏱️ **Time:** 2 menit

**Tujuan:** Langsung eksekusi tanpa banyak teori

---

### **Option 2: Untuk User yang Ingin Instruksi Terurut**
📄 **File:** [STEP_BY_STEP_INSTRUCTIONS.md](./STEP_BY_STEP_INSTRUCTIONS.md)
- ✅ Urutan jelas: Step 1, 2, 3, dst
- ✅ Penjelasan apa guna setiap command
- ✅ Output yang diharapkan dijelaskan
- ✅ Troubleshooting included
- ⏱️ **Time:** 15-20 menit + execution

**Tujuan:** Follow instruction dengan pemahaman

---

## 📖 **PERLU TROUBLESHOOTING? BUKA INI:**

### **Option 3: Untuk Error Spesifik (NIK/BPJS tidak terdeteksi)**
📄 **File:** [DIAGNOSIS_NIK_BPJS_NOT_DETECTED.md](./DIAGNOSIS_NIK_BPJS_NOT_DETECTED.md)
- ✅ Step-by-step diagnosis
- ✅ Test setiap layer (container, DB, API)
- ✅ Solution untuk setiap diagnosis result
- ✅ Verification checklist
- ⏱️ **Time:** 20-30 menit

**Tujuan:** Debug masalah NIK/BPJS tidak terdeteksi

---

## 🔧 **PERLU REFERENSI LENGKAP? BUKA INI:**

### **Option 4: Untuk Full Documentation**
📄 **File:** [DATABASE_SETUP.md](./DATABASE_SETUP.md)
- ✅ Full troubleshooting guide
- ✅ Semua error codes & solutions
- ✅ Endpoint testing examples
- ✅ Environment variable reference
- ✅ Common commands reference
- ✅ Database architecture explained
- ⏱️ **Time:** 1-2 jam (reference document)

**Tujuan:** Complete reference manual

---

## ⚡ **QUICK START (5 MENIT)? BUKA INI:**

### **Option 5: Untuk Quick Start**
📄 **File:** [DATABASE_QUICKSTART.md](./DATABASE_QUICKSTART.md)
- ✅ Setup dalam 5 menit
- ✅ 3 pilihan setup method
- ✅ Valid test data
- ✅ Quick problem solutions
- ⏱️ **Time:** 5 menit

**Tujuan:** Super cepat, minimal info

---

## 📋 **SUMMARY & OVERVIEW:**

### **Option 6: Untuk Overview Lengkap**
📄 **File:** [DATABASE_FIX_SUMMARY.md](./DATABASE_FIX_SUMMARY.md)
- ✅ Problem statement
- ✅ Solutions implemented
- ✅ Valid test data
- ✅ Setup instructions
- ✅ Verification checklist
- ⏱️ **Time:** 10 menit (read)

**Tujuan:** Understand what was fixed

---

## 🎯 DECISION TREE

```
Saya ingin...

├─ Langsung eksekusi commands?
│  └─→ COMMAND_CHEAT_SHEET.md ⭐

├─ Follow instruction yang terurut?
│  └─→ STEP_BY_STEP_INSTRUCTIONS.md ⭐

├─ Debug NIK/BPJS tidak terdeteksi?
│  └─→ DIAGNOSIS_NIK_BPJS_NOT_DETECTED.md

├─ Setup dalam 5 menit?
│  └─→ DATABASE_QUICKSTART.md

├─ Baca full documentation?
│  └─→ DATABASE_SETUP.md

└─ Understand apa yang di-fix?
   └─→ DATABASE_FIX_SUMMARY.md
```

---

## 📁 FILE STRUKTUR

```
backend/
├── STEP_BY_STEP_INSTRUCTIONS.md  ← Step-by-step dengan penjelasan
├── COMMAND_CHEAT_SHEET.md         ← Hanya commands (copy-paste)
├── DATABASE_SETUP.md              ← Full documentation & reference
├── DATABASE_QUICKSTART.md         ← 5 menit quick start
├── DIAGNOSIS_NIK_BPJS_NOT_DETECTED.md ← Debug guide
├── DATABASE_FIX_SUMMARY.md        ← What was fixed
├── DOCUMENTATION_GUIDE.md         ← File ini
│
├── docker-compose.yml             ← Docker config
├── run_backend.bat                ← One-click setup (Windows)
├── manage_db.bat                  ← Database manager (Windows)
├── manage_db.ps1                  ← Database manager (PowerShell)
│
├── cmd/
│  └── database-util/main.go       ← CLI utility
│  └── server/main.go              ← Backend API
│
└── internal/
   ├── database/
   │  ├── postgres.go              ← DB connection & migration
   │  └── reset.go                 ← NEW: Database reset utility
   ├── service/
   ├── repository/
   └── model/
```

---

## 🚀 RECOMMENDED FLOW

### **For First Time Users:**
1. **Read:** [STEP_BY_STEP_INSTRUCTIONS.md](./STEP_BY_STEP_INSTRUCTIONS.md)
2. **Execute:** Follow each step
3. **If error:** Check [DIAGNOSIS_NIK_BPJS_NOT_DETECTED.md](./DIAGNOSIS_NIK_BPJS_NOT_DETECTED.md)
4. **Bookmark:** [DATABASE_SETUP.md](./DATABASE_SETUP.md) untuk reference

### **For Advanced Users:**
1. **Read:** [COMMAND_CHEAT_SHEET.md](./COMMAND_CHEAT_SHEET.md)
2. **Execute:** Copy-paste commands
3. **If error:** [DATABASE_SETUP.md](./DATABASE_SETUP.md) section troubleshooting

### **For Troubleshooting:**
1. **Diagnose:** [DIAGNOSIS_NIK_BPJS_NOT_DETECTED.md](./DIAGNOSIS_NIK_BPJS_NOT_DETECTED.md)
2. **Reference:** [DATABASE_SETUP.md](./DATABASE_SETUP.md)
3. **Execute:** Follow solution

---

## 💾 VALID TEST DATA (ALL DOCS)

Semua file di atas berisi test data yang sama:

```
NIK 1: 1206202612340001  → BPJS: 0001234567890  → Queue: 120620260101
NIK 2: 1206202612340002  → BPJS: 0009876543210  → Queue: 120620260102
NIK 3: 1206202612340003  → BPJS: 0001112223334  → Queue: 120620260103
```

---

## 📞 QUICK LINKS

| Need | File | Purpose |
|------|------|---------|
| Commands only | [COMMAND_CHEAT_SHEET.md](./COMMAND_CHEAT_SHEET.md) | Copy-paste commands |
| Step by step | [STEP_BY_STEP_INSTRUCTIONS.md](./STEP_BY_STEP_INSTRUCTIONS.md) | Detailed walkthrough |
| Troubleshoot | [DIAGNOSIS_NIK_BPJS_NOT_DETECTED.md](./DIAGNOSIS_NIK_BPJS_NOT_DETECTED.md) | Debug guide |
| Full reference | [DATABASE_SETUP.md](./DATABASE_SETUP.md) | Complete documentation |
| Quick setup | [DATABASE_QUICKSTART.md](./DATABASE_QUICKSTART.md) | 5 minute setup |
| What's new | [DATABASE_FIX_SUMMARY.md](./DATABASE_FIX_SUMMARY.md) | What was fixed |

---

## ✅ BEFORE YOU START

Make sure you have:
- [ ] Docker installed
- [ ] Go installed (1.25.0+)
- [ ] Flutter installed
- [ ] Terminal/PowerShell ready

---

## 🎯 YOUR NEXT STEP

Pick **ONE** of these:

1. **Want to just run it?** → Go to [COMMAND_CHEAT_SHEET.md](./COMMAND_CHEAT_SHEET.md)
2. **Want detailed walkthrough?** → Go to [STEP_BY_STEP_INSTRUCTIONS.md](./STEP_BY_STEP_INSTRUCTIONS.md)
3. **Have an error?** → Go to [DIAGNOSIS_NIK_BPJS_NOT_DETECTED.md](./DIAGNOSIS_NIK_BPJS_NOT_DETECTED.md)
4. **Need reference?** → Go to [DATABASE_SETUP.md](./DATABASE_SETUP.md)

---

**Happy coding! 🚀**

---

**Last Updated:** April 29, 2026  
**Status:** ✅ Ready to use
