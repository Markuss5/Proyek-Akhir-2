package repository

import (
	"database/sql"
	"gliranku/models"
)

type PoliRepository struct {
	DB *sql.DB
}

func NewPoliRepository(db *sql.DB) *PoliRepository {
	return &PoliRepository{DB: db}
}

// FindAll returns all polyclinics from the real hospital tbpoli table
func (r *PoliRepository) FindAll() ([]models.Poliklinik, error) {
	query := `
		SELECT "IdPoli", "NamaPoli"
		FROM tbpoli
		ORDER BY "NamaPoli" ASC
	`

	rows, err := r.DB.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []models.Poliklinik
	for rows.Next() {
		var p models.Poliklinik
		err := rows.Scan(&p.PolyID, &p.PolyName)
		if err != nil {
			return nil, err
		}
		p.IsActive = true
		results = append(results, p)
	}
	return results, nil
}

func (r *PoliRepository) FindByID(id int) (*models.Poliklinik, error) {
	query := `SELECT "IdPoli", "NamaPoli" FROM tbpoli WHERE "IdPoli" = $1`

	var p models.Poliklinik
	err := r.DB.QueryRow(query, id).Scan(&p.PolyID, &p.PolyName)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	p.IsActive = true
	return &p, nil
}
