package repo

import (
	"context"
	"database/sql"

	"giliran_ku_backend/models"
)

func (r *Repository) FindPatientByNikOrBpjs(ctx context.Context, value string) (models.Patient, error) {
	row := r.DB.QueryRowContext(ctx, `
		SELECT nik, patient_name, phone, email, bpjs_number
		FROM pasien
		WHERE nik = $1 OR bpjs_number = $1
		LIMIT 1
	`, value)

	var patient models.Patient
	var phone sql.NullString
	var email sql.NullString
	var bpjs sql.NullString

	if err := row.Scan(&patient.Nik, &patient.Name, &phone, &email, &bpjs); err != nil {
		return models.Patient{}, err
	}
	if phone.Valid {
		patient.Phone = phone.String
	}
	if email.Valid {
		patient.Email = email.String
	}
	if bpjs.Valid {
		patient.BpjsNumber = bpjs.String
	}

	return patient, nil
}
