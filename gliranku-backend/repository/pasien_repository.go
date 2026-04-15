package repository

import (
	"database/sql"
	"gliranku/models"
)

type PasienRepository struct {
	DB *sql.DB
}

func NewPasienRepository(db *sql.DB) *PasienRepository {
	return &PasienRepository{DB: db}
}

func (r *PasienRepository) FindByNIK(nik string) (*models.Pasien, error) {
	query := `SELECT "NIK", "noRM", "patientName", phone, email FROM "Pasien" WHERE "NIK" = $1`

	var pasien models.Pasien
	err := r.DB.QueryRow(query, nik).Scan(
		&pasien.NIK,
		&pasien.NoRM,
		&pasien.PatientName,
		&pasien.Phone,
		&pasien.Email,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return &pasien, nil
}
