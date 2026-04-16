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

// FindByNIK retrieves a patient by their NIK
func (r *PasienRepository) FindByNIK(nik string) (*models.Pasien, error) {
	query := `
		SELECT nik, norm, patientname, phone, email,
		       "noBPJS", "golonganDarah", "tanggalLahir", alamat, "jenisKelamin"
		FROM pasien WHERE nik = $1
	`

	var p models.Pasien
	err := r.DB.QueryRow(query, nik).Scan(
		&p.NIK, &p.NoRM, &p.PatientName, &p.Phone, &p.Email,
		&p.NoBPJS, &p.GolonganDarah, &p.TanggalLahir, &p.Alamat, &p.JenisKelamin,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return &p, nil
}

// Register creates a new patient record
func (r *PasienRepository) Register(p *models.Pasien) (*models.Pasien, error) {
	query := `
		INSERT INTO pasien (nik, patientname, phone)
		VALUES ($1, $2, $3)
		RETURNING nik, norm, patientname, phone, email,
		          "noBPJS", "golonganDarah", "tanggalLahir", alamat, "jenisKelamin"
	`

	var result models.Pasien
	err := r.DB.QueryRow(query, p.NIK, p.PatientName, p.Phone).Scan(
		&result.NIK, &result.NoRM, &result.PatientName, &result.Phone, &result.Email,
		&result.NoBPJS, &result.GolonganDarah, &result.TanggalLahir, &result.Alamat, &result.JenisKelamin,
	)
	if err != nil {
		return nil, err
	}
	return &result, nil
}

// UpdateProfile updates a patient's profile data
func (r *PasienRepository) UpdateProfile(p *models.Pasien) (*models.Pasien, error) {
	query := `
		UPDATE pasien SET
			patientname = COALESCE($2, patientname),
			phone = COALESCE($3, phone),
			email = COALESCE($4, email),
			"noBPJS" = COALESCE($5, "noBPJS"),
			"golonganDarah" = COALESCE($6, "golonganDarah"),
			"tanggalLahir" = COALESCE($7::date, "tanggalLahir"),
			alamat = COALESCE($8, alamat),
			"jenisKelamin" = COALESCE($9, "jenisKelamin")
		WHERE nik = $1
		RETURNING nik, norm, patientname, phone, email,
		          "noBPJS", "golonganDarah", "tanggalLahir", alamat, "jenisKelamin"
	`

	var result models.Pasien
	err := r.DB.QueryRow(query,
		p.NIK, &p.PatientName, p.Phone, p.Email,
		p.NoBPJS, p.GolonganDarah, p.TanggalLahir, p.Alamat, p.JenisKelamin,
	).Scan(
		&result.NIK, &result.NoRM, &result.PatientName, &result.Phone, &result.Email,
		&result.NoBPJS, &result.GolonganDarah, &result.TanggalLahir, &result.Alamat, &result.JenisKelamin,
	)
	if err != nil {
		return nil, err
	}
	return &result, nil
}
