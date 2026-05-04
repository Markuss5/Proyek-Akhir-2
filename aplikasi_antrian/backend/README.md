# Backend API (Golang)

Backend ini dipakai untuk validasi data dari aplikasi Flutter.

## Arsitektur

1. Flutter kirim request ke API Golang.
2. Golang validasi input dan query ke PostgreSQL.
3. Golang kirim response JSON ke Flutter.

## Endpoint

- GET /health
- POST /api/v1/validate/nik
- POST /api/v1/validate/bpjs-or-nik
- POST /api/v1/validate/queue-code

## Payload Contoh

POST /api/v1/validate/nik

```json
{
  "nik": "1203010101010001"
}
```

POST /api/v1/validate/bpjs-or-nik

```json
{
  "input": "0001234567890"
}
```

POST /api/v1/validate/queue-code

```json
{
  "queueCode": "120620260101"
}
```

## Menjalankan Backend

1. Jalankan PostgreSQL (pilih salah satu):

Opsi A - Docker Compose

```bash
cd backend
docker compose up -d
```

Opsi B - PostgreSQL lokal

Pastikan service PostgreSQL aktif dan database `aplikasi_antrian` sudah dibuat.

2. Jalankan API Golang:

```bash
cd backend
go mod tidy
go run ./cmd/server
```

Server default berjalan di port 8081.

Saat startup, backend akan otomatis membuat tabel dan seed dummy data jika tabel masih kosong.

## Environment Variable (opsional)

- API_ADDR (default :8081)
- DATABASE_URL (default postgres://postgres:postgres@localhost:5432/aplikasi_antrian?sslmode=disable)

## Format Validasi Input

### NIK (National ID)
- **Format:** 16 digit angka
- **Contoh:** 1203010101010001
- **Validasi:** Harus pas 16 digit, hanya angka

### No. BPJS
- **Format:** 13 digit angka
- **Contoh:** 0001234567890
- **Validasi:** Harus pas 13 digit, hanya angka

### Queue Code
- **Format:** 12 digit angka
- **Contoh:** 120620260101
- **Validasi:** Harus pas 12 digit, hanya angka (0-9)
