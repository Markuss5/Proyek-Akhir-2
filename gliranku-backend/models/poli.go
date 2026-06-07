package models

type Poliklinik struct {
	PolyID      int     `json:"poly_id"`
	PolyName    string  `json:"poly_name"`
	KodePoli    *string `json:"kode_poli,omitempty"`
	Description *string `json:"description,omitempty"`
	IsActive    bool    `json:"is_active"`
}