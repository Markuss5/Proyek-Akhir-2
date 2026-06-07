package models

type Spesialis struct {
	ID           int    `json:"id"`
	Kelompok     int    `json:"kelompok"`
	Jenis        int    `json:"jenis"`
	Nama         string `json:"nama"`
	NamaAlias    string `json:"nama_alias"`
	JumlahTenaga *int   `json:"jumlah_tenaga,omitempty"`
}