package handlers

import "giliran_ku_backend/services"

type AppHandlers struct {
	Health       *HealthHandler
	Master       *MasterHandler
	Consultation *ConsultationHandler
	Pharmacy     *PharmacyHandler
	Booking      *BookingHandler
	Pdf          *PdfHandler
}

func NewAppHandlers(service *services.QueueService, pdfOutputDir string) *AppHandlers {
	return &AppHandlers{
		Health:       &HealthHandler{},
		Master:       &MasterHandler{service: service},
		Consultation: &ConsultationHandler{service: service},
		Pharmacy:     &PharmacyHandler{service: service},
		Booking:      &BookingHandler{service: service},
		Pdf:          NewPdfHandler(pdfOutputDir),
	}
}
