package response

type AntrianResponse struct {
	NoAntrian   string `json:"no_antrian"`
	KodeBooking string `json:"kode_booking"`
	Poliklinik  string `json:"poliklinik"`
	Dokter      string `json:"dokter"`
	Tanggal     string `json:"tanggal"`
	Waktu       string `json:"waktu"`
	Pembayaran  string `json:"pembayaran"`
	Status      string `json:"status"`
}

type CekNIKResponse struct {
	IsValid    bool   `json:"is_valid"`
	IsBPJS     bool   `json:"is_bpjs"`
	NamaPasien string `json:"nama_pasien,omitempty"`
	Message    string `json:"message,omitempty"`
}

type LayananResponse struct {
	ID   int    `json:"id"`
	Nama string `json:"nama"`
}