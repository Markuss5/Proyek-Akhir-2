# 🐳 INSTALL DOCKER (Prerequisite)

## ❌ MASALAH

Docker tidak terinstall di sistem Anda. Tanpa Docker, tidak bisa menjalankan PostgreSQL.

## ✅ SOLUSI: Install Docker Desktop

### **STEP 1: Download Docker Desktop**

1. Buka: https://www.docker.com/products/docker-desktop
2. Klik: "Download for Windows"
3. File akan download: `Docker Desktop Installer.exe` (~700 MB)

### **STEP 2: Install Docker Desktop**

1. Double-click: `Docker Desktop Installer.exe`
2. Tunggu installation (~5-10 menit)
3. Follow wizard (semua default OK)
4. Klik: "Install"
5. Tunggu selesai
6. Restart komputer (penting!)

### **STEP 3: Verify Installation**

Setelah restart, buka PowerShell baru dan jalankan:

```powershell
docker --version
```

**Expected Output:**
```
Docker version 26.1.x, build xxxxx
```

Jika output seperti di atas → Docker sudah terinstall! ✅

### **STEP 4: Start Docker Desktop**

1. Cari: "Docker Desktop" di Start Menu
2. Klik untuk membuka
3. Tunggu sampai tray icon berubah hijau
4. (Akan membuka aplikasi dengan Docker whale icon)

**Important:** Docker Desktop harus tetap berjalan di background!

---

## ⚠️ CHECKLIST SEBELUM LANJUT

- [ ] Docker Desktop sudah didownload
- [ ] Docker Desktop sudah di-install
- [ ] Komputer sudah di-restart
- [ ] Docker Desktop sudah dibuka (icon hijau di taskbar)
- [ ] `docker --version` return version number

---

## ⏱️ ESTIMASI WAKTU

- Download: 5-10 menit (tergantung internet)
- Install: 5-10 menit
- Restart: 2-3 menit
- **Total: ~20 menit**

---

## 🆘 JIKA ADA ERROR

### **Error: "Docker daemon is not running"**
- Buka Docker Desktop dari Start Menu
- Tunggu icon di taskbar berubah hijau

### **Error: "Permission denied"**
- Run PowerShell as Administrator
- Jalankan command lagi

### **Error: "WSL 2 installation is incomplete"**
- Install Windows Terminal dari Microsoft Store
- Atau install WSL 2 manually (advanced)

---

## ✅ SETELAH DOCKER INSTALLED

Kemudian jalankan:

```powershell
cd "d:\Folder Semester 4\Pengembangan Aplikasi Mobile\Week 9\Praktikum\aplikasi_antrian\backend"
docker-compose up -d
```

Maka PostgreSQL akan langsung berjalan! 🚀

---

**Silakan install Docker terlebih dahulu, kemudian balik ke sini dan saya jalankan sisanya!**
