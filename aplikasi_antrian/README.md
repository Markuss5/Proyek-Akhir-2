# Aplikasi Antrian RSUD Porsea

Project ini sekarang menggunakan arsitektur client-server:

1. Flutter (UI) mengirim request ke API.
2. Golang menerima request, validasi format input, lalu query ke PostgreSQL.
3. Golang mengirim response JSON ke Flutter.
4. Flutter menampilkan hasil validasi ke user.

## Struktur Utama

- [lib](lib): aplikasi Flutter.
- [backend](backend): REST API Golang + layer database.

## Endpoint API

- `GET /health`
- `POST /api/v1/validate/nik`
- `POST /api/v1/validate/bpjs-or-nik`
- `POST /api/v1/validate/queue-code`

## Menjalankan Backend (Golang)

```bash
cd backend
docker compose up -d
go mod tidy
go run ./cmd/server
```

Default server: `http://localhost:8081`

## Menjalankan Flutter

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8081
```

Catatan:
- Untuk Android Emulator gunakan `10.0.2.2` agar bisa akses backend di host machine.
- Untuk device fisik/LAN, ganti `API_BASE_URL` ke IP komputer yang menjalankan API.

## Lokasi Integrasi API di Flutter

- [lib/services/validation_service.dart](lib/services/validation_service.dart): seluruh request HTTP ke backend.
- [lib/models/validation_models.dart](lib/models/validation_models.dart): model response API.

## Lokasi Backend Golang

- [backend/cmd/server/main.go](backend/cmd/server/main.go): bootstrap server.
- [backend/internal/transport/httpapi/handler.go](backend/internal/transport/httpapi/handler.go): endpoint handler.
- [backend/internal/service/validation_service.go](backend/internal/service/validation_service.go): business validation.
- [backend/internal/repository/validation_repository.go](backend/internal/repository/validation_repository.go): query database.
- [backend/internal/database/postgres.go](backend/internal/database/postgres.go): koneksi PostgreSQL + migration + seed data awal.

## Database

Database kami gunakan **PostgreSQL 16** via Docker Compose.

- **Database Name:** `aplikasi_antrian`
- **Connection String:** `postgres://postgres:postgres@localhost:5432/aplikasi_antrian?sslmode=disable`
- **Username:** postgres
- **Password:** postgres
- **Port:** 5432

### PENTING: PostgreSQL HARUS Menyala

Tanpa PostgreSQL running:
- ❌ API tidak bisa validasi data
- ❌ Tidak bisa tambah/update database
- ❌ Aplikasi Flutter akan crash saat coba input

### Startup Sequence

```bash
# Terminal 1: Jalankan PostgreSQL
cd backend
docker compose up -d

# Terminal 2: Jalankan API Golang
cd backend
go run ./cmd/server

# Terminal 3: Jalankan Flutter
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8081
```

## Format Validasi Input

### NIK (National ID)
- **Format:** 16 digit angka
- **Contoh:** 1203010101010001

### No. BPJS
- **Format:** 13 digit angka
- **Contoh:** 0001234567890

### Queue Code
- **Format:** 12 digit angka (0-9)
- **Contoh:** 120620260101
