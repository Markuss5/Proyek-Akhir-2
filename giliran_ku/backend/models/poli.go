package models

type Poli struct {
	ID          string `json:"id"`
	Name        string `json:"name"`
	Description string `json:"description,omitempty"`
	IsActive    bool   `json:"is_active,omitempty"`
}
