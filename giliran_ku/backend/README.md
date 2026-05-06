# Backend (Go)

Backend API untuk aplikasi antrian (konsultasi, farmasi, dan booking).

## Setup cepat
1. Salin file .env.example menjadi .env lalu isi koneksi database.
2. Jalankan migrasi tambahan:
	 - psql -d giliran_ku_db -f migrations/002_additions.sql
	 - psql -d giliran_ku_db -f migrations/003_seed.sql
	 - psql -d giliran_ku_db -f migrations/004_admission_queue.sql
	 - psql -d giliran_ku_db -f migrations/005_bpjs_referral.sql
	 - psql -d giliran_ku_db -f migrations/006_expand_ids.sql
3. Install dependency:
	 - go mod tidy
4. Jalankan server:
	 - go run ./cmd/api

## Endpoint
- GET /health
- GET /polis
- GET /doctors?poli_id=POLI-UMUM
- POST /patients/validate
- POST /tickets/consultation/bpjs
- POST /tickets/consultation/general
- POST /tickets/pharmacy
- GET /tickets/booking/{code}
- POST /tickets/pdf

## Contoh request
Validasi pasien:

curl -X POST http://localhost:8080/patients/validate \
	-H "Content-Type: application/json" \
	-d '{"nik_or_bpjs":"3201002003004001"}'

Tiket konsultasi BPJS:

curl -X POST http://localhost:8080/tickets/consultation/bpjs \
	-H "Content-Type: application/json" \
	-d '{"nik_or_bpjs":"3201002003004001"}'

Tiket konsultasi umum:

curl -X POST http://localhost:8080/tickets/consultation/general \
	-H "Content-Type: application/json" \
	-d '{"nik":"3201002003004002","poli_id":"POLI-UMUM","doctor_id":"DR-001"}'

Tiket farmasi:

curl -X POST http://localhost:8080/tickets/pharmacy

Cetak tiket dari kode booking:

curl http://localhost:8080/tickets/booking/BK001

Upload PDF tiket:

curl -X POST http://localhost:8080/tickets/pdf \
	-F "file=@ticket.pdf"
