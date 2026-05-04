package database

import (
	"database/sql"
	"fmt"

	_ "github.com/lib/pq"
)

func OpenDatabase(databaseURL string) (*sql.DB, error) {
	db, err := sql.Open("postgres", databaseURL)
	if err != nil {
		return nil, fmt.Errorf("open postgres: %w", err)
	}

	db.SetMaxOpenConns(10)
	db.SetMaxIdleConns(5)

	if err := db.Ping(); err != nil {
		_ = db.Close()
		return nil, fmt.Errorf("ping postgres: %w", err)
	}

	if err := migrate(db); err != nil {
		_ = db.Close()
		return nil, err
	}

	if err := seed(db); err != nil {
		_ = db.Close()
		return nil, err
	}

	return db, nil
}

func migrate(db *sql.DB) error {
	statements := []string{
		`CREATE TABLE IF NOT EXISTS patients (
			id TEXT PRIMARY KEY,
			nik VARCHAR(16) NOT NULL UNIQUE,
			bpjs_number VARCHAR(13) NOT NULL UNIQUE,
			name TEXT NOT NULL,
			queue_number TEXT NOT NULL
		);`,
		`CREATE TABLE IF NOT EXISTS queue_codes (
			queue_code VARCHAR(12) PRIMARY KEY,
			queue_number TEXT NOT NULL,
			patient_id TEXT NOT NULL REFERENCES patients(id),
			clinic_name TEXT NOT NULL,
			doctor_name TEXT NOT NULL,
			schedule_info TEXT NOT NULL,
			created_at TIMESTAMPTZ NOT NULL
		);`,
		`CREATE TABLE IF NOT EXISTS pharmacy_queues (
			id TEXT PRIMARY KEY,
			pharmacy_queue_code VARCHAR(12) NOT NULL,
			queue_number TEXT NOT NULL,
			patient_id TEXT NOT NULL REFERENCES patients(id),
			clinic_name TEXT,
			doctor_name TEXT,
			schedule_info TEXT,
			created_at TIMESTAMPTZ NOT NULL
		);`,
	}

	for _, statement := range statements {
		if _, err := db.Exec(statement); err != nil {
			return fmt.Errorf("migrate postgres: %w", err)
		}
	}

	return nil
}

func seed(db *sql.DB) error {
	// Start transaction for atomic seeding
	tx, err := db.Begin()
	if err != nil {
		return fmt.Errorf("begin transaction: %w", err)
	}
	defer tx.Rollback()

	// Check if data already exists
	var count int
	if err := tx.QueryRow("SELECT COUNT(*) FROM patients").Scan(&count); err != nil {
		return fmt.Errorf("check existing data: %w", err)
	}

	if count > 0 {
		// Data already exists, skip seeding
		if err := tx.Commit(); err != nil {
			return fmt.Errorf("commit transaction: %w", err)
		}
		return nil
	}

	// Insert seed data
	seedStatements := []string{
		`INSERT INTO patients (id, nik, bpjs_number, name, queue_number) VALUES
			('PT-0001', '1206202612340001', '0001234567890', 'Miranti R. Siregar', 'N101'),
			('PT-0002', '1206202612340002', '0009876543210', 'Bintang H. Simanjuntak', 'N102'),
			('PT-0003', '1206202612340003', '0001112223334', 'Roni Tua Sinaga', 'N103');`,
		`INSERT INTO queue_codes (queue_code, queue_number, patient_id, clinic_name, doctor_name, schedule_info, created_at) VALUES
			('120620260101', '106', 'PT-0001', 'POLI BEDAH', 'dr. Reynold Sianturi, Sp.B', 'Pelayanan 19/04/2026 09:00', '2026-04-19T08:41:00+07:00'),
			('120620260102', '107', 'PT-0002', 'POLI UMUM', 'dr. Eva S. Lumban Gaol', 'Pelayanan 19/04/2026 10:00', '2026-04-19T08:47:00+07:00'),
			('120620260103', '108', 'PT-0003', 'POLI PENYAKIT DALAM', 'dr. Yohana P. Siahaan, Sp.PD', 'Pelayanan 19/04/2026 11:15', '2026-04-19T08:52:00+07:00');`,
		`INSERT INTO pharmacy_queues (id, pharmacy_queue_code, queue_number, patient_id, clinic_name, doctor_name, schedule_info, created_at) VALUES
			('PQ-0001', 'FARM001', 'F001', 'PT-0001', 'FARMASI', '-', 'Pengambilan obat', '2026-04-19T09:30:00+07:00'),
			('PQ-0002', 'FARM002', 'F002', 'PT-0002', 'FARMASI', '-', 'Pengambilan obat', '2026-04-19T10:15:00+07:00'),
			('PQ-0003', 'FARM003', 'F003', 'PT-0003', 'FARMASI', '-', 'Pengambilan obat', '2026-04-19T11:00:00+07:00');`,
	}

	for _, statement := range seedStatements {
		if _, err := tx.Exec(statement); err != nil {
			return fmt.Errorf("seed data: %w", err)
		}
	}

	// Commit transaction
	if err := tx.Commit(); err != nil {
		return fmt.Errorf("commit transaction: %w", err)
	}

	return nil
}
