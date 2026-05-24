package response

type AntrianResponse struct {
	NoAntrian     string `json:"no_antrian"`
	NoAntrianPoli string `json:"no_antrian_poli"`
	KodeBooking   string `json:"kode_booking"`
	Poliklinik    string `json:"poliklinik"`
	Dokter        string `json:"dokter"`
	Tanggal       string `json:"tanggal"`
	Waktu         string `json:"waktu"`
	Pembayaran    string `json:"pembayaran"`
	Status        string `json:"status"`
	Source        string `json:"source,omitempty"`
	NoRM          string `json:"no_rm,omitempty"`
	NamaPasien    string `json:"nama_pasien,omitempty"`
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

type RujukanResponse struct {
	NoRujukan   string `json:"no_rujukan"`
	Tanggal     string `json:"tanggal"`
	PoliNama    string `json:"poli_nama"`
	PoliID      int    `json:"poli_id"`
	AsalFaskes  string `json:"asal_faskes"`
	Diagnosa    string `json:"diagnosa"`
}