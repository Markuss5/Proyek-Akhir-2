package repo

import (
	"context"

	"giliran_ku_backend/models"
)

func (r *Repository) GetDoctorsByPoli(ctx context.Context, poliID string) ([]models.Doctor, error) {
	rows, err := r.DB.QueryContext(ctx, `
		SELECT doctor_id, doctor_name, poli_id, specialization, phone, status
		FROM dokter
		WHERE poli_id = $1
		ORDER BY doctor_name
	`, poliID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var doctors []models.Doctor
	for rows.Next() {
		var doctor models.Doctor
		if err := rows.Scan(
			&doctor.ID,
			&doctor.Name,
			&doctor.PoliID,
			&doctor.Specialization,
			&doctor.Phone,
			&doctor.Status,
		); err != nil {
			return nil, err
		}
		doctors = append(doctors, doctor)
	}

	return doctors, rows.Err()
}

func (r *Repository) GetDoctorByID(ctx context.Context, doctorID string) (models.Doctor, error) {
	var doctor models.Doctor
	row := r.DB.QueryRowContext(ctx, `
		SELECT doctor_id, doctor_name, poli_id, specialization, phone, status
		FROM dokter
		WHERE doctor_id = $1
	`, doctorID)
	if err := row.Scan(
		&doctor.ID,
		&doctor.Name,
		&doctor.PoliID,
		&doctor.Specialization,
		&doctor.Phone,
		&doctor.Status,
	); err != nil {
		return models.Doctor{}, err
	}
	return doctor, nil
}

func (r *Repository) GetFirstDoctorByPoli(ctx context.Context, poliID string) (models.Doctor, error) {
	var doctor models.Doctor
	row := r.DB.QueryRowContext(ctx, `
		SELECT doctor_id, doctor_name, poli_id, specialization, phone, status
		FROM dokter
		WHERE poli_id = $1
		ORDER BY doctor_name
		LIMIT 1
	`, poliID)
	if err := row.Scan(
		&doctor.ID,
		&doctor.Name,
		&doctor.PoliID,
		&doctor.Specialization,
		&doctor.Phone,
		&doctor.Status,
	); err != nil {
		return models.Doctor{}, err
	}
	return doctor, nil
}
