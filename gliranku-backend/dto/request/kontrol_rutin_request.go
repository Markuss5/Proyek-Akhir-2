package request

type CreateKontrolRutinRequest struct {
	NIK         string `json:"nik" binding:"required"`
	ControlDate string `json:"control_date" binding:"required"`
	Notes       string `json:"notes"`
}