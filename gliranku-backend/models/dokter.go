package models

type Dokter struct {
	DoctorID       int    `json:"doctor_id"`
	DoctorName     string `json:"doctor_name"`
	Specialization string `json:"specialization"`
	PolyID         int    `json:"poly_id"`
	PolyName       string `json:"poly_name,omitempty"`
	Phone          string `json:"phone,omitempty"`
	Status         bool   `json:"status"`
	Schedule       string `json:"schedule,omitempty"` // e.g. "Senin, Kamis, Jumat"
}
