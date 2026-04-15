package models

import "time"

type KontrolRutin struct {
	ControlID   int       `json:"control_id"`
	ControlDate time.Time `json:"control_date"`
	Notes       *string   `json:"notes,omitempty"`
	CreatedAt   time.Time `json:"created_at"`
	NIK         string    `json:"nik"`
}
