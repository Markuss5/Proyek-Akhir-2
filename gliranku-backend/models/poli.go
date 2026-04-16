package models

type Poliklinik struct {
	PolyID      int     `json:"poly_id"`
	PolyName    string  `json:"poly_name"`
	Description *string `json:"description,omitempty"`
	IsActive    bool    `json:"is_active"`
}
