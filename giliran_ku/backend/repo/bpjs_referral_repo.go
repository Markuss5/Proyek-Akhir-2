package repo

import "context"

type BpjsReferral struct {
	PatientNik string
	PoliID     string
	DoctorID   string
}

func (r *Repository) GetBpjsReferralByNik(ctx context.Context, nik string) (BpjsReferral, error) {
	row := r.DB.QueryRowContext(ctx, `
		SELECT patient_nik, poli_id, doctor_id
		FROM bpjs_referral
		WHERE patient_nik = $1
	`, nik)

	var referral BpjsReferral
	if err := row.Scan(&referral.PatientNik, &referral.PoliID, &referral.DoctorID); err != nil {
		return BpjsReferral{}, err
	}

	return referral, nil
}
