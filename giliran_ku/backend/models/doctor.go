package models

type Doctor struct {
	ID             string `json:"id"`
	Name           string `json:"name"`
	PoliID         string `json:"poli_id"`
	Specialization string `json:"specialization,omitempty"`
	Phone          string `json:"phone,omitempty"`
	Status         string `json:"status,omitempty"`
}
