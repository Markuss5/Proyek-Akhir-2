package repo

import (
	"context"
	"database/sql"

	"giliran_ku_backend/models"
)

func (r *Repository) GetActivePolis(ctx context.Context) ([]models.Poli, error) {
	rows, err := r.DB.QueryContext(ctx, `
		SELECT poli_id, poli_name, description, is_active
		FROM poliklinik
		WHERE is_active = true
		ORDER BY poli_name
	`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var polis []models.Poli
	for rows.Next() {
		var poli models.Poli
		var description sql.NullString
		if err := rows.Scan(&poli.ID, &poli.Name, &description, &poli.IsActive); err != nil {
			return nil, err
		}
		if description.Valid {
			poli.Description = description.String
		}
		polis = append(polis, poli)
	}

	return polis, rows.Err()
}

func (r *Repository) GetPoliByID(ctx context.Context, poliID string) (models.Poli, error) {
	var poli models.Poli
	var description sql.NullString
	row := r.DB.QueryRowContext(ctx, `
		SELECT poli_id, poli_name, description, is_active
		FROM poliklinik
		WHERE poli_id = $1
	`, poliID)
	if err := row.Scan(&poli.ID, &poli.Name, &description, &poli.IsActive); err != nil {
		return models.Poli{}, err
	}
	if description.Valid {
		poli.Description = description.String
	}
	return poli, nil
}

func (r *Repository) GetDefaultPoli(ctx context.Context) (models.Poli, error) {
	var poli models.Poli
	var description sql.NullString
	row := r.DB.QueryRowContext(ctx, `
		SELECT poli_id, poli_name, description, is_active
		FROM poliklinik
		WHERE is_active = true
		ORDER BY poli_name
		LIMIT 1
	`)
	if err := row.Scan(&poli.ID, &poli.Name, &description, &poli.IsActive); err != nil {
		return models.Poli{}, err
	}
	if description.Valid {
		poli.Description = description.String
	}
	return poli, nil
}
