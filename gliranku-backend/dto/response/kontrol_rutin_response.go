package response

import (
	"gliranku/models"
	"time"
)

type KontrolRutinResponse struct {
	ControlID   int       `json:"control_id"`
	ControlDate string    `json:"control_date"`
	Notes       *string   `json:"notes,omitempty"`
	CreatedAt   time.Time `json:"created_at"`
	NIK         string    `json:"nik"`
}

func FromKontrolRutin(kr models.KontrolRutin) KontrolRutinResponse {
	return KontrolRutinResponse{
		ControlID:   kr.ControlID,
		ControlDate: kr.ControlDate.Format("2006-01-02"),
		Notes:       kr.Notes,
		CreatedAt:   kr.CreatedAt,
		NIK:         kr.NIK,
	}
}

func FromKontrolRutinList(list []models.KontrolRutin) []KontrolRutinResponse {
	var results []KontrolRutinResponse
	for _, kr := range list {
		results = append(results, FromKontrolRutin(kr))
	}
	return results
}
