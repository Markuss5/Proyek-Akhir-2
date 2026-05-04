# Fitur: Cetak Antrian Melalui Kode Booking/Kode Antrian

## Deskripsi
Fitur ketiga di Home Screen yang memungkinkan user memasukkan **Kode Antrian** (12 digit) untuk mencetak ulang kartu antrian mereka tanpa perlu mengisi form ulang.

---

## Format Kode Antrian
- **Format**: `XXXXXXXXXX` (12 karakter)
- **Tipe**: Angka (`0-9`) atau Alphanumeric (`A-Z0-9`)
- **Contoh**: `000123010501` atau `E01500010301`

---

## API Endpoint Backend

### 1. POST Validate Queue Code

```
POST /api/v1/validate/queue-code
Content-Type: application/json

{
  "queueCode": "000123010501"
}
```

**Response - Success (200):**
```json
{
  "isValid": true,
  "message": "Kode antrian valid.",
  "data": {
    "queueCode": "000123010501",
    "queueNumber": "N101",
    "patientName": "Miranti R. Siregar",
    "clinicName": "POLI UMUM",
    "doctorName": "dr. Test Dokter",
    "scheduleInfo": "09:00-12:00",
    "createdAt": "2026-03-02T10:15:00Z"
  }
}
```

**Response - Error (200):**
```json
{
  "isValid": false,
  "message": "Kode antrian tidak ditemukan pada database.",
  "data": null
}
```

---

## Database Schema - Queue Codes Table

```sql
CREATE TABLE queue_codes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id VARCHAR(10) NOT NULL REFERENCES patients(id),
  queue_code VARCHAR(12) NOT NULL UNIQUE,
  queue_number VARCHAR(10) NOT NULL,
  clinic_name VARCHAR(100),
  doctor_name VARCHAR(100),
  schedule_info VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index untuk performa query
CREATE INDEX idx_queue_codes_code ON queue_codes(queue_code);
CREATE INDEX idx_queue_codes_patient_id ON queue_codes(patient_id);
```

---

## Contoh Data di Database

```sql
-- Insert queue code untuk pasien
INSERT INTO queue_codes (patient_id, queue_code, queue_number, clinic_name, doctor_name, schedule_info, created_at)
VALUES 
  ('PT-0001', 'E01500010301', 'N101', 'POLI UMUM', 'dr. Yunita V.Tampubolon, SpPD', '10:00-14:00', NOW()),
  ('PT-0002', 'E02500020402', 'N102', 'POLI THT', 'dr. Toman G.M Simamora, SpTHT-KL', '11:00-19:00', NOW()),
  ('PT-0003', 'E03500030503', 'N103', 'POLI GIGI', 'dr. Yusak Parlaungan Simanjuntak, SpKJ', '08:00-13:00', NOW());

-- Query untuk cek kode antrian
SELECT * FROM queue_codes WHERE queue_code = 'E01500010301';

-- Query join dengan patient data
SELECT 
  qc.queue_code,
  qc.queue_number,
  p.nik,
  p.name as patient_name,
  qc.clinic_name,
  qc.doctor_name,
  qc.schedule_info,
  qc.created_at
FROM queue_codes qc
JOIN patients p ON p.id = qc.patient_id
WHERE qc.queue_code = 'E01500010301';
```

---

## cURL Command - Test API

```bash
# Test dengan kode antrian yang valid
curl -X POST http://localhost:8081/api/v1/validate/queue-code \
  -H "Content-Type: application/json" \
  -d '{"queueCode":"E01500010301"}'

# Test dengan kode antrian yang tidak ada
curl -X POST http://localhost:8081/api/v1/validate/queue-code \
  -H "Content-Type: application/json" \
  -d '{"queueCode":"999999999999"}'
```

---

## PowerShell Command - Test API

```powershell
# Test validate queue code
$body = @{
    queueCode = "E01500010301"
} | ConvertTo-Json

$response = Invoke-WebRequest -Uri "http://localhost:8081/api/v1/validate/queue-code" `
  -Method POST `
  -Headers @{"Content-Type"="application/json"} `
  -Body $body

$response.Content | ConvertFrom-Json | Format-List
```

---

## Flutter Code - Validate Queue Code

```dart
// File: lib/services/validation_service.dart

// Sudah ada method:
static Future<QueueCodeValidationResponse> validateQueueCode(
  String queueCode,
) async {
  try {
    final response = await _client.post(
      Uri.parse('$_baseUrl/validate/queue-code'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'queueCode': queueCode}),
    );

    if (response.statusCode == 200) {
      return QueueCodeValidationResponse.fromJson(
        json.decode(response.body),
      );
    } else {
      return QueueCodeValidationResponse(
        isValid: false,
        message: 'Server error',
      );
    }
  } catch (e) {
    return QueueCodeValidationResponse(
      isValid: false,
      message: 'Connection error: $e',
    );
  }
}
```

---

## Go Code - Backend Implementation

File: `backend/internal/service/validation_service.go`

```go
func (s *ValidationService) ValidateQueueCode(input string) (model.QueueCodeValidationResponse, error) {
	queueCode := normalizeQueueCode(input)
	if !queueCodeRegex.MatchString(queueCode) {
		return model.QueueCodeValidationResponse{
			IsValid: false,
			Message: "Kode antrian harus 12 karakter (huruf/angka).",
		}, nil
	}

	record, err := s.repo.FindQueueByCode(queueCode)
	if err != nil {
		return model.QueueCodeValidationResponse{}, err
	}
	if record == nil {
		return model.QueueCodeValidationResponse{
			IsValid: false,
			Message: "Kode antrian tidak ditemukan pada database.",
		}, nil
	}

	return model.QueueCodeValidationResponse{
		IsValid: true,
		Message: "Kode antrian valid.",
		Data: &model.QueueVerificationData{
			QueueCode:    record.QueueCode,
			QueueNumber:  record.QueueNumber,
			PatientName:  record.PatientName,
			ClinicName:   record.ClinicName,
			DoctorName:   record.DoctorName,
			ScheduleInfo: record.ScheduleInfo,
			CreatedAt:    record.CreatedAt,
		},
	}, nil
}
```

---

## Alur Fitur: Cetak Antrian Melalui Kode

```
Home Screen
  ↓
User Tap "Cetak Antrian Melalui Kode"
  ↓
QueueCodeInputScreen
  ↓
User Input Kode Antrian (12 digit)
  ↓
Tekan "Verifikasi"
  ↓
ValidationService.validateQueueCode(code)
  ↓
Backend API: POST /api/v1/validate/queue-code
  ↓
Database Query: SELECT * FROM queue_codes WHERE queue_code = ?
  ↓
[VALID] → PrintService.printOrExportQueueTicket()
  ↓
QueueVerificationSuccessScreen (Tampil data antrian)
  ↓
User bisa:
  - Cetak Kartas (print)
  - Kembali ke Menu Utama
```

---

## Testing Steps

### 1. Setup Backend
```bash
cd backend
docker-compose up -d  # Pastikan PostgreSQL running
go run ./cmd/server
```

### 2. Insert Test Data
```sql
-- Koneksi ke database via psql atau DBeaver
INSERT INTO queue_codes (patient_id, queue_code, queue_number, clinic_name, doctor_name, schedule_info)
VALUES ('PT-0001', 'TEST123456789', 'N101', 'POLI UMUM', 'dr. Test', '09:00-12:00');
```

### 3. Test via cURL
```bash
curl -X POST http://localhost:8081/api/v1/validate/queue-code \
  -H "Content-Type: application/json" \
  -d '{"queueCode":"TEST123456789"}'
```

### 4. Test via Flutter App
- Jalankan `flutter run`
- Tap "Cetak Antrian Melalui Kode"
- Input kode: `TEST123456789`
- Tekan "Verifikasi"

---

## Kode Antrian yang Sudah Tersedia

Jika Anda sudah menjalankan seed data dari database:

| Kode Antrian | Queue Number | Pasien | Poli |
|---|---|---|---|
| E01500010301 | N101 | Miranti R. Siregar | POLI UMUM |
| E02500020402 | N102 | Bintang H. Simanjuntak | POLI THT |
| E03500030503 | N103 | Roni Tua Sinaga | POLI GIGI |

**Test Code:** `E01500010301`

---

## Troubleshooting

### Problem: Kode tidak ditemukan
- Pastikan kode sudah di-insert ke database
- Cek format kode: 12 karakter

### Problem: API error "connection refused"
- Pastikan backend running: `go run ./cmd/server`
- Pastikan database running: `docker-compose ps`

### Problem: Print tidak berfungsi
- Pastikan PrintService konfigurasi sudah benar
- Cek permissions folder Download di device/emulator
