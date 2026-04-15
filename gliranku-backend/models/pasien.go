package models

type Pasien struct {
	NIK         string  `json:"nik"`
	NoRM        *string `json:"no_rm,omitempty"`
	PatientName string  `json:"patient_name"`
	Phone       *string `json:"phone,omitempty"`
	Email       *string `json:"email,omitempty"`
}
