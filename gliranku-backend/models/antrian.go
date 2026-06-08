package models

import "time"

type Antrian struct {
	NoAntrian       string    `json:"no_antrian"`
	NoAntrianPoli   string    `json:"no_antrian_poli"`
	KodeBooking     string    `json:"kode_booking"`
	NIK             string    `json:"nik"`
	NamaPasien   string    `json:"nama_pasien"`
	Telepon      string    `json:"telepon"`
	PoliID       int       `json:"poli_id"`
	DokterID     *int      `json:"dokter_id,omitempty"`
	Tanggal      time.Time `json:"tanggal"`
	WaktuMulai   string    `json:"waktu_mulai"`
	WaktuSelesai string    `json:"waktu_selesai"`
	Pembayaran   string    `json:"pembayaran"`
	IsPasienLama bool      `json:"is_pasien_lama"`
	Status       string    `json:"status"`
	Source       string    `json:"source"`
	NoRM         string    `json:"no_rm"`
	PrintCount   int       `json:"print_count"`
}

type KunjunganStatPoli struct {
	PolyID   int    `json:"poly_id"`
	PolyName string `json:"poly_name"`
	Jumlah   int    `json:"jumlah"`
}

type AntrianResponseExtended struct {
	NoAntrian     string
	NoAntrianPoli string
	KodeBooking   string
	Poliklinik    string
	Dokter       string
	Tanggal      time.Time
	WaktuMulai   string
	WaktuSelesai string
	Pembayaran   string
	Status       string
	PrintCount   int
}