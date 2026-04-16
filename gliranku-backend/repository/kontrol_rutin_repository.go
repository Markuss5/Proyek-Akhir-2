package repository

import (
	"database/sql"
	"gliranku/models"
	"time"
)

type KontrolRutinRepository struct {
	DB *sql.DB
}

func NewKontrolRutinRepository(db *sql.DB) *KontrolRutinRepository {
	return &KontrolRutinRepository{DB: db}
}

func (r *KontrolRutinRepository) Create(kontrolRutin *models.KontrolRutin) (*models.KontrolRutin, error) {
	query := `
		INSERT INTO kontrol_rutin (controldate, notes, createdat, nik)
		VALUES ($1, $2, $3, $4)
		RETURNING controlid, controldate, notes, createdat, nik
	`

	var result models.KontrolRutin
	err := r.DB.QueryRow(
		query,
		kontrolRutin.ControlDate,
		kontrolRutin.Notes,
		time.Now(),
		kontrolRutin.NIK,
	).Scan(
		&result.ControlID,
		&result.ControlDate,
		&result.Notes,
		&result.CreatedAt,
		&result.NIK,
	)
	if err != nil {
		return nil, err
	}
	return &result, nil
}

func (r *KontrolRutinRepository) FindByNIK(nik string) ([]models.KontrolRutin, error) {
	query := `
		SELECT controlid, controldate, notes, createdat, nik
		FROM kontrol_rutin
		WHERE nik = $1
		ORDER BY controldate ASC
	`

	rows, err := r.DB.Query(query, nik)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []models.KontrolRutin
	for rows.Next() {
		var kr models.KontrolRutin
		err := rows.Scan(&kr.ControlID, &kr.ControlDate, &kr.Notes, &kr.CreatedAt, &kr.NIK)
		if err != nil {
			return nil, err
		}
		results = append(results, kr)
	}
	return results, nil
}

func (r *KontrolRutinRepository) FindUpcoming(days int) ([]models.KontrolRutin, error) {
	query := `
		SELECT controlid, controldate, notes, createdat, nik
		FROM kontrol_rutin
		WHERE controldate BETWEEN CURRENT_DATE AND CURRENT_DATE + $1 * INTERVAL '1 day'
		ORDER BY controldate ASC
	`

	rows, err := r.DB.Query(query, days)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []models.KontrolRutin
	for rows.Next() {
		var kr models.KontrolRutin
		err := rows.Scan(&kr.ControlID, &kr.ControlDate, &kr.Notes, &kr.CreatedAt, &kr.NIK)
		if err != nil {
			return nil, err
		}
		results = append(results, kr)
	}
	return results, nil
}

func (r *KontrolRutinRepository) FindByID(id int) (*models.KontrolRutin, error) {
	query := `
		SELECT controlid, controldate, notes, createdat, nik
		FROM kontrol_rutin
		WHERE controlid = $1
	`

	var kr models.KontrolRutin
	err := r.DB.QueryRow(query, id).Scan(
		&kr.ControlID, &kr.ControlDate, &kr.Notes, &kr.CreatedAt, &kr.NIK,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return &kr, nil
}

func (r *KontrolRutinRepository) FindAll() ([]models.KontrolRutin, error) {
	query := `
		SELECT controlid, controldate, notes, createdat, nik
		FROM kontrol_rutin
		ORDER BY controldate DESC
	`

	rows, err := r.DB.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []models.KontrolRutin
	for rows.Next() {
		var kr models.KontrolRutin
		err := rows.Scan(&kr.ControlID, &kr.ControlDate, &kr.Notes, &kr.CreatedAt, &kr.NIK)
		if err != nil {
			return nil, err
		}
		results = append(results, kr)
	}
	return results, nil
}
