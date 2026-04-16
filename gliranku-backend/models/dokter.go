package models

type Dokter struct {
	DoctorID   int    `json:"doctor_id"`
	DoctorName string `json:"doctor_name"`
	PolyID     int    `json:"poly_id"`
	Status     bool   `json:"status"`
}
