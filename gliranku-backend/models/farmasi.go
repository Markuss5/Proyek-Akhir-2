package models

import "time"

type TiketFarmasi struct {
	QueueNumber int       `json:"queue_number"`
	CreatedAt   time.Time `json:"created_at"`
	NoAntrian   string    `json:"no_antrian"`
}