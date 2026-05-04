package repository

import (
	"database/sql"
	"errors"

	"aplikasi_antrian/backend/internal/model"
)

type ValidationRepository struct {
	db *sql.DB
}

func NewValidationRepository(db *sql.DB) *ValidationRepository {
	return &ValidationRepository{db: db}
}

func (r *ValidationRepository) FindPatientByNIK(nik string) (*model.Patient, error) {
	const query = `
		SELECT id, nik, bpjs_number, name, queue_number
		FROM patients
		WHERE nik = $1
	`

	row := r.db.QueryRow(query, nik)
	patient := model.Patient{}
	if err := row.Scan(&patient.ID, &patient.NIK, &patient.BPJSNumber, &patient.Name, &patient.QueueNumber); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}

	return &patient, nil
}

func (r *ValidationRepository) FindPatientByBPJS(bpjsNumber string) (*model.Patient, error) {
	const query = `
		SELECT id, nik, bpjs_number, name, queue_number
		FROM patients
		WHERE bpjs_number = $1
	`

	row := r.db.QueryRow(query, bpjsNumber)
	patient := model.Patient{}
	if err := row.Scan(&patient.ID, &patient.NIK, &patient.BPJSNumber, &patient.Name, &patient.QueueNumber); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}

	return &patient, nil
}

func (r *ValidationRepository) FindQueueByCode(queueCode string) (*model.QueueRecord, error) {
	const query = `
		SELECT q.queue_code, q.queue_number, p.name, q.clinic_name, q.doctor_name, q.schedule_info, q.created_at
		FROM queue_codes q
		INNER JOIN patients p ON p.id = q.patient_id
		WHERE q.queue_code = $1
	`

	row := r.db.QueryRow(query, queueCode)
	record := model.QueueRecord{}
	if err := row.Scan(
		&record.QueueCode,
		&record.QueueNumber,
		&record.PatientName,
		&record.ClinicName,
		&record.DoctorName,
		&record.ScheduleInfo,
		&record.CreatedAt,
	); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}

	return &record, nil
}

func (r *ValidationRepository) GetLastPharmacyQueueNumber() (int, error) {
	const query = `
		SELECT COALESCE(MAX(CAST(SUBSTRING(queue_number, 2) AS INTEGER)), 0)
		FROM pharmacy_queues
	`

	var lastNumber int
	if err := r.db.QueryRow(query).Scan(&lastNumber); err != nil {
		return 0, err
	}

	return lastNumber, nil
}

func (r *ValidationRepository) CreatePharmacyQueue(pharmacyQueue *model.PharmacyQueue) error {
	const query = `
		INSERT INTO pharmacy_queues 
		(id, pharmacy_queue_code, queue_number, patient_id, clinic_name, doctor_name, schedule_info, created_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
	`

	_, err := r.db.Exec(
		query,
		pharmacyQueue.ID,
		pharmacyQueue.PharmacyQueueCode,
		pharmacyQueue.QueueNumber,
		pharmacyQueue.PatientID,
		pharmacyQueue.ClinicName,
		pharmacyQueue.DoctorName,
		pharmacyQueue.ScheduleInfo,
		pharmacyQueue.CreatedAt,
	)

	if err != nil {
		return err
	}

	return nil
}
