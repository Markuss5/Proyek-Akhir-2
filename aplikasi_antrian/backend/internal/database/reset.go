package database

import (
	"database/sql"
	"fmt"
	"log"
)

// ResetDatabase drops all tables and recreates them with seed data
// Use this when you need a clean slate (e.g., corrupted data, duplicate issues)
func ResetDatabase(db *sql.DB) error {
	log.Println("[DATABASE] Starting database reset...")

	// Drop existing tables in correct order (respect foreign keys)
	dropStatements := []string{
		"DROP TABLE IF EXISTS pharmacy_queues CASCADE;",
		"DROP TABLE IF EXISTS queue_codes CASCADE;",
		"DROP TABLE IF EXISTS patients CASCADE;",
	}

	for _, statement := range dropStatements {
		if _, err := db.Exec(statement); err != nil {
			return fmt.Errorf("drop table failed: %w", err)
		}
		log.Printf("[DATABASE] Executed: %s", statement)
	}

	log.Println("[DATABASE] All tables dropped successfully")

	// Recreate tables
	if err := migrate(db); err != nil {
		return err
	}

	log.Println("[DATABASE] Tables recreated successfully")

	// Seed fresh data
	if err := seed(db); err != nil {
		return err
	}

	log.Println("[DATABASE] Fresh seed data inserted successfully")
	return nil
}

// ValidateDatabaseIntegrity checks if data is properly seeded
func ValidateDatabaseIntegrity(db *sql.DB) error {
	log.Println("[DATABASE] Validating database integrity...")

	// Check patients count
	var patientCount int
	err := db.QueryRow("SELECT COUNT(*) FROM patients").Scan(&patientCount)
	if err != nil {
		return fmt.Errorf("count patients failed: %w", err)
	}
	log.Printf("[DATABASE] Found %d patients", patientCount)

	if patientCount == 0 {
		return fmt.Errorf("no patients found in database - seeding may have failed")
	}

	// Check queue_codes count
	var queueCount int
	err = db.QueryRow("SELECT COUNT(*) FROM queue_codes").Scan(&queueCount)
	if err != nil {
		return fmt.Errorf("count queue_codes failed: %w", err)
	}
	log.Printf("[DATABASE] Found %d queue codes", queueCount)

	// List all NIK and BPJS in database
	log.Println("[DATABASE] Available data in database:")
	rows, err := db.Query(`
		SELECT id, nik, bpjs_number, name, queue_number 
		FROM patients 
		ORDER BY id
	`)
	if err != nil {
		return fmt.Errorf("query patients failed: %w", err)
	}
	defer rows.Close()

	for rows.Next() {
		var id, nik, bpjs, name, queueNum string
		if err := rows.Scan(&id, &nik, &bpjs, &name, &queueNum); err != nil {
			return err
		}
		log.Printf("  [PATIENT] ID: %s | NIK: %s | BPJS: %s | Name: %s | Queue: %s", id, nik, bpjs, name, queueNum)
	}

	return rows.Err()
}
