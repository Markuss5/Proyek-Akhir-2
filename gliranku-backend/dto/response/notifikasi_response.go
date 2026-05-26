package response

import (
	"gliranku/models"
	"time"
)

type NotifikasiResponse struct {
	NotificationID int        `json:"notification_id"`
	Message        string     `json:"message"`
	ScheduledDate  string     `json:"scheduled_date"`
	IsSent         bool       `json:"is_sent"`
	SentAt         *time.Time `json:"sent_at,omitempty"`
	NIK            string     `json:"nik"`
}

func FromNotifikasi(n models.Notifikasi) NotifikasiResponse {
	return NotifikasiResponse{
		NotificationID: n.NotificationID,
		Message:        n.Message,
		ScheduledDate:  n.ScheduledDate.Format(time.RFC3339),
		IsSent:         n.IsSent,
		SentAt:         n.SentAt,
		NIK:            n.NIK,
	}
}

func FromNotifikasiList(list []models.Notifikasi) []NotifikasiResponse {
	var results []NotifikasiResponse
	for _, n := range list {
		results = append(results, FromNotifikasi(n))
	}
	return results
}