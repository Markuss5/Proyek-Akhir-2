# Aplikasi Sistem Antrian RSUD Porsea - Dokumentasi Struktur

## 📁 Struktur Project

```
lib/
├── main.dart                    # Entry point aplikasi
├── screens/
│   └── home_screen.dart        # Screen utama aplikasi
├── widgets/
│   ├── header_widget.dart      # Header dengan logo, jam, tanggal
│   ├── service_button_widget.dart # Button untuk layanan
│   └── footer_widget.dart      # Footer dengan copyright
├── models/
│   └── service_model.dart      # Model data layanan
├── logic/                       # (Untuk future: Provider, Bloc, Cubit)
└── utils/
    ├── constants.dart          # Konstanta warna, spacing, typography
    └── theme.dart              # Theme dan text styles

backend/
├── cmd/server/main.go          # Entry point API Golang
├── internal/
│   ├── database/postgres.go    # Koneksi PostgreSQL + migration + seed data
│   ├── model/validation.go     # DTO request/response
│   ├── repository/validation_repository.go   # Query ke database
│   ├── service/validation_service.go         # Logic validasi
│   └── transport/httpapi/handler.go          # Routing endpoint API
├── docker-compose.yml           # Menjalankan PostgreSQL via Docker
└── .env.example                 # Contoh environment backend
```

## 🔄 Alur Arsitektur (Flutter -> Golang -> Database)

1. User input data di Flutter (NIK/BPJS/Kode Antrian).
2. Flutter kirim request HTTP ke API Golang.
3. Golang validasi format input.
4. Golang query data ke PostgreSQL.
5. Golang kirim response JSON ke Flutter.
6. Flutter menampilkan hasil validasi di UI.

## 🎨 Komponen UI

### Header Widget
- Logo rumah sakit
- Judul dan subtitle
- Tampilan tanggal dan jam real-time
- Warna: Hijau (#5FA092)

### Service Buttons
1. **Antrian Konsultasi** - Hijau (#5FA092)
   - Icon: Stethoscope
   - Deskripsi: Pendaftaran dan nomor antrian

2. **Antrian Farmasi** - Lime (#8CC63F)
   - Icon: Pills/Medication
   - Deskripsi: Nomor antrian farmasi

3. **Cetak Kertas Antrian** - Biru (#0066CC)
   - Icon: QR Code
   - Deskripsi: Print via smartphone dengan kode antrian

### Footer Widget
- Copyright text
- Warna: Dark Gray (#4D4D4D)

## 🎯 Fitur UI Saat Ini

✅ Responsive design (Portrait & Landscape)  
✅ Real-time clock dan tanggal  
✅ Hover effects pada buttons  
✅ Color-coded service buttons  
✅ Professional hospital branding  

## 📝 File yang Dibuat

### Constants & Theme
- `utils/constants.dart` - Warna, spacing, typography, hospital info
- `utils/theme.dart` - Theme material & text styles

### Models
- `models/service_model.dart` - Definisi service dengan icons dan warna

### Widgets
- `widgets/header_widget.dart` - Komponen header
- `widgets/service_button_widget.dart` - Komponen tombol layanan
- `widgets/footer_widget.dart` - Komponen footer

### Screens
- `screens/home_screen.dart` - Screen utama yang merangkai semua widgets

### Main App
- `main.dart` - Entry point dengan theme configuration

## 🚀 Langkah Selanjutnya

1. **Auth/Security** - Tambah API key/JWT antar Flutter dan backend
2. **Database Production** - Hardening PostgreSQL (backup, replica, index tuning)
3. **Observability** - Tambah structured logging dan metrics
4. **Testing** - Unit test service backend dan integration test endpoint
5. **Deployment** - Containerize backend (Docker) dan setup CI/CD

## 💾 Dependencies

- `intl: ^0.19.0` - Untuk formatting tanggal dengan locale Indonesia
- `http: ^0.13.6` - Untuk API calls (sudah ada)
- `audioplayers: ^5.2.1` - Untuk sound notification (sudah ada)

## 🎬 Instalasi & Run

```bash
# Get dependencies
flutter pub get

# Run aplikasi
flutter run
```

---

**Struktur project sudah siap untuk implementasi logic dan functionalities selanjutnya!**
