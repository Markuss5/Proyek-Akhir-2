package request

type AntrianRequest struct {
	NIK          string `json:"nik" validate:"required,len=16"`
	NamaPasien   string `json:"nama_pasien" validate:"required"`
	Telepon      string `json:"telepon" validate:"required"`
	PoliID       int    `json:"poli_id" validate:"required,min=1"`
	DokterID     *int   `json:"dokter_id,omitempty"`
	IsPasienLama bool   `json:"is_pasien_lama"`
}

type CekNIKRequest struct {
	NIK string `json:"nik" validate:"required,len=16"`
}