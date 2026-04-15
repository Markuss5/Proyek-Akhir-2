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
		INSERT INTO "Kontrol_Rutin" ("controlDate", notes, "createdAt", "NIK")
		VALUES ($1, $2, $3, $4)
		RETURNING "controlID", "controlDate", notes, "createdAt", "NIK"
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
		SELECT "controlID", "controlDate", notes, "createdAt", "NIK"
		FROM "Kontrol_Rutin"
		WHERE "NIK" = $1
		ORDER BY "controlDate" ASC
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
		SELECT "controlID", "controlDate", notes, "createdAt", "NIK"
		FROM "Kontrol_Rutin"
		WHERE "controlDate" BETWEEN CURRENT_DATE AND CURRENT_DATE + $1 * INTERVAL '1 day'
		ORDER BY "controlDate" ASC
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
		SELECT "controlID", "controlDate", notes, "createdAt", "NIK"
		FROM "Kontrol_Rutin"
		WHERE "controlID" = $1
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
