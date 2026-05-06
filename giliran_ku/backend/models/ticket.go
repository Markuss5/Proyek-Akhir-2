package models

import "time"

type Ticket struct {
	ID          string    `json:"id"`
	QueueNumber int       `json:"queue_number"`
	AdmissionNumber int   `json:"admission_number,omitempty"`
	PoliQueueCode string  `json:"poli_queue_code,omitempty"`
	Type        string    `json:"type"`
	Poli        *Poli     `json:"poli,omitempty"`
	Doctor      *Doctor   `json:"doctor,omitempty"`
	Patient     *Patient  `json:"patient,omitempty"`
	BookingCode *string   `json:"booking_code,omitempty"`
	CreatedAt   time.Time `json:"created_at"`
}
