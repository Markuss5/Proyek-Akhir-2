package models

import "time"

type Notifikasi struct {
	NotificationID int        `json:"notification_id"`
	Message        string     `json:"message"`
	ScheduledDate  time.Time  `json:"scheduled_date"`
	IsSent         bool       `json:"is_sent"`
	SentAt         *time.Time `json:"sent_at,omitempty"`
	NIK            string     `json:"nik"`
}
