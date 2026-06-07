package models

type Informasi struct {
	ID          int               `json:"id"`
	Name        string            `json:"name"`
	Description string            `json:"description"`
	Vision      string            `json:"vision"`
	Mission     []string          `json:"mission"`
	OpHours     map[string]string `json:"op_hours"`
	Facilities  []string          `json:"facilities"`
	Address     string            `json:"address"`
	Phone       string            `json:"phone"`
	Email       string            `json:"email"`
}