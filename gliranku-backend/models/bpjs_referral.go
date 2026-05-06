package models

type BpjsReferral struct {
	PatientNik string `json:"patient_nik"`
	PoliID     int    `json:"poli_id"`
	DoctorID   int    `json:"doctor_id"`
}
