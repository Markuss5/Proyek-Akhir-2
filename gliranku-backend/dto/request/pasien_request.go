package request

type LoginPasienRequest struct {
	NIK  string `json:"nik" binding:"required"`
	Name string `json:"name" binding:"required"`
}

type UpdatePasienProfileRequest struct {
	NIK           string  `json:"nik" binding:"required"`
	PatientName   string  `json:"patient_name"`
	Phone         *string `json:"phone"`
	Email         *string `json:"email"`
	NoBPJS        *string `json:"no_bpjs"`
	GolonganDarah *string `json:"golongan_darah"`
	TanggalLahir  *string `json:"tanggal_lahir"`
	Alamat        *string `json:"alamat"`
	JenisKelamin  *string `json:"jenis_kelamin"`
}
