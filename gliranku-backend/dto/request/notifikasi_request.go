package request

type CreateNotifikasiRequest struct {
	NIK           string `json:"nik" binding:"required"`
	Message       string `json:"message" binding:"required"`
	ScheduledDate string `json:"scheduled_date" binding:"required"` // format: YYYY-MM-DD
}
