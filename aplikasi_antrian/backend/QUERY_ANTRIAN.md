# Query Data Antrian dari Database

## 1. SQL Query - Cari Antrian Berdasarkan NIK

```sql
-- Query 1: Cari Pasien + Antrian Consultation
SELECT 
    p.id as patient_id,
    p.nik,
    p.name,
    p.queue_number,
    qc.queue_code,
    qc.clinic_name,
    qc.doctor_name,
    qc.schedule_info,
    qc.created_at
FROM patients p
LEFT JOIN queue_codes qc ON p.id = qc.patient_id
WHERE p.nik = '1203010101010001';

-- Query 2: Cari Antrian Farmasi Berdasarkan NIK
SELECT 
    p.id as patient_id,
    p.nik,
    p.name,
    pq.queue_number,
    pq.created_at
FROM patients p
LEFT JOIN pharmacy_queues pq ON p.id = pq.patient_id
WHERE p.nik = '1203010101010001';

-- Query 3: Semua Antrian (Consultation + Pharmacy) untuk NIK Tertentu
SELECT 
    p.id,
    p.nik,
    p.name,
    'consultation' as queue_type,
    qc.queue_code,
    qc.queue_number,
    qc.clinic_name,
    qc.doctor_name,
    qc.created_at
FROM patients p
LEFT JOIN queue_codes qc ON p.id = qc.patient_id
WHERE p.nik = '1203010101010001' AND qc.queue_code IS NOT NULL

UNION ALL

SELECT 
    p.id,
    p.nik,
    p.name,
    'pharmacy' as queue_type,
    NULL as queue_code,
    pq.queue_number,
    'FARMASI' as clinic_name,
    '' as doctor_name,
    pq.created_at
FROM patients p
LEFT JOIN pharmacy_queues pq ON p.id = pq.patient_id
WHERE p.nik = '1203010101010001' AND pq.queue_number IS NOT NULL;
```

## 2. Test Data - Insert NIK Baru

Jika Anda ingin menambah NIK `1203010101010001` ke database:

```sql
-- Insert Patient
INSERT INTO patients (id, nik, name, queue_number, created_at)
VALUES (
    'PT-' || LPAD((SELECT COUNT(*) + 1 FROM patients)::text, 4, '0'),
    '1203010101010001',
    'Nama Pasien',
    'N' || LPAD((SELECT COUNT(*) + 1 FROM patients)::text, 3, '0'),
    NOW()
);

-- Atau manual:
INSERT INTO patients (id, nik, name, queue_number, created_at)
VALUES ('PT-0004', '1203010101010001', 'Nama Pasien Test', 'N104', NOW());

-- Insert Queue untuk Consultation
INSERT INTO queue_codes (patient_id, queue_code, queue_number, clinic_name, doctor_name, schedule_info, created_at)
VALUES (
    'PT-0004',
    'E001',
    'N104',
    'POLI UMUM',
    'dr. Test Dokter',
    '09:00-12:00',
    NOW()
);
```

## 3. cURL Command - Test API

```bash
# Test dengan NIK yang sudah ada di database
curl -X POST http://localhost:8081/api/v1/validate/nik \
  -H "Content-Type: application/json" \
  -d '{"nik":"1206202612340001"}'

# Expected Response:
# {
#   "isValid": true,
#   "message": "NIK valid.",
#   "patientId": "PT-0001",
#   "queueNumber": "N101",
#   "patientName": "Miranti R. Siregar"
# }

# Test dengan NIK baru (1203010101010001) - jika sudah diinsert
curl -X POST http://localhost:8081/api/v1/validate/nik \
  -H "Content-Type: application/json" \
  -d '{"nik":"1203010101010001"}'
```

## 4. PowerShell Command - Run Test

```powershell
# Dari folder project
cd backend

# Jalankan database utility untuk lihat semua data
go run ./cmd/database-util -validate

# Jalankan server
go run ./cmd/server

# Di terminal lain, test API:
$body = @{
    nik = "1206202612340001"
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8081/api/v1/validate/nik" `
  -Method POST `
  -Headers @{"Content-Type"="application/json"} `
  -Body $body
```

## 5. Go Code - Function untuk Query

```go
// File: backend/internal/repository/validation_repository.go
// Tambahkan function baru:

// GetQueueByPatientNIK - Ambil semua antrian untuk NIK tertentu
func (r *ValidationRepository) GetQueueByPatientNIK(nik string) ([]*model.QueueRecord, error) {
	const query = `
		SELECT 
			q.queue_code, 
			q.queue_number, 
			p.name, 
			q.clinic_name, 
			q.doctor_name, 
			q.schedule_info, 
			q.created_at
		FROM queue_codes q
		INNER JOIN patients p ON p.id = q.patient_id
		WHERE p.nik = $1
		ORDER BY q.created_at DESC
	`

	rows, err := r.db.Query(query, nik)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var records []*model.QueueRecord
	for rows.Next() {
		record := model.QueueRecord{}
		if err := rows.Scan(
			&record.QueueCode,
			&record.QueueNumber,
			&record.PatientName,
			&record.ClinicName,
			&record.DoctorName,
			&record.ScheduleInfo,
			&record.CreatedAt,
		); err != nil {
			return nil, err
		}
		records = append(records, &record)
	}

	if err = rows.Err(); err != nil {
		return nil, err
	}

	return records, nil
}

// GetPharmacyQueueByNIK - Ambil antrian farmasi untuk NIK tertentu
func (r *ValidationRepository) GetPharmacyQueueByNIK(nik string) ([]*model.PharmacyQueue, error) {
	const query = `
		SELECT 
			pq.id,
			pq.patient_id,
			pq.queue_number,
			pq.created_at
		FROM pharmacy_queues pq
		INNER JOIN patients p ON p.id = pq.patient_id
		WHERE p.nik = $1
		ORDER BY pq.created_at DESC
	`

	rows, err := r.db.Query(query, nik)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var queues []*model.PharmacyQueue
	for rows.Next() {
		queue := model.PharmacyQueue{}
		if err := rows.Scan(
			&queue.ID,
			&queue.PatientID,
			&queue.QueueNumber,
			&queue.CreatedAt,
		); err != nil {
			return nil, err
		}
		queues = append(queues, &queue)
	}

	if err = rows.Err(); err != nil {
		return nil, err
	}

	return queues, nil
}
```

---

## Testing Steps:

1. **Pastikan Backend Running**
   ```bash
   cd backend
   docker-compose up -d
   go run ./cmd/server
   ```

2. **Insert Data Test (Optional)**
   ```bash
   # Jika NIK 1203010101010001 belum ada di database
   go run ./cmd/database-util -reset  # Reset ke data awal
   # Atau query INSERT di database admin tool
   ```

3. **Test Query**
   - Gunakan SQL query di database client (DBeaver, pgAdmin)
   - Atau test API dengan cURL/Postman

4. **Test API**
   ```bash
   curl -X POST http://localhost:8081/api/v1/validate/nik \
     -H "Content-Type: application/json" \
     -d '{"nik":"1203010101010001"}'
   ```
