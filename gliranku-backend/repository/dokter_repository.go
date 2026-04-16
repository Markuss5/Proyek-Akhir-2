package repository

import (
	"database/sql"
	"gliranku/models"
)

type DokterRepository struct {
	DB *sql.DB
}

func NewDokterRepository(db *sql.DB) *DokterRepository {
	return &DokterRepository{DB: db}
}

// FindByPolyID returns doctors assigned to a specific polyclinic
// Uses the category table which maps doctors to polis with schedule info
func (r *DokterRepository) FindByPolyID(polyID int) ([]models.Dokter, error) {
	query := `
		SELECT c.id, c.namadokter, c."IdPoli"
		FROM category c
		WHERE c."IdPoli" = $1 AND c.app = 1
		ORDER BY c.namadokter ASC
	`

	rows, err := r.DB.Query(query, polyID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []models.Dokter
	for rows.Next() {
		var d models.Dokter
		err := rows.Scan(&d.DoctorID, &d.DoctorName, &d.PolyID)
		if err != nil {
			return nil, err
		}
		d.Status = true
		results = append(results, d)
	}
	return results, nil
}

// FindAll returns all active doctors from the category table
func (r *DokterRepository) FindAll() ([]models.Dokter, error) {
	query := `
		SELECT c.id, c.namadokter, c."IdPoli"
		FROM category c
		WHERE c.app = 1
		ORDER BY c.namadokter ASC
	`

	rows, err := r.DB.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []models.Dokter
	for rows.Next() {
		var d models.Dokter
		err := rows.Scan(&d.DoctorID, &d.DoctorName, &d.PolyID)
		if err != nil {
			return nil, err
		}
		d.Status = true
		results = append(results, d)
	}
	return results, nil
}
