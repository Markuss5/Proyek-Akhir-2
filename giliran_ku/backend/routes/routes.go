package routes

import (
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"

	"giliran_ku_backend/handlers"
)

func NewRouter(h *handlers.AppHandlers) http.Handler {
	r := chi.NewRouter()
	r.Use(middleware.RequestID)
	r.Use(middleware.RealIP)
	r.Use(middleware.Logger)
	r.Use(middleware.Recoverer)

	r.Get("/health", h.Health.Health)

	r.Get("/polis", h.Master.ListPolis)
	r.Get("/doctors", h.Master.ListDoctors)

	r.Post("/patients/validate", h.Consultation.ValidatePatient)

	r.Route("/tickets", func(r chi.Router) {
		r.Post("/consultation/bpjs", h.Consultation.CreateBpjsTicket)
		r.Post("/consultation/general", h.Consultation.CreateGeneralTicket)
		r.Post("/pharmacy", h.Pharmacy.CreatePharmacyTicket)
		r.Get("/booking/{code}", h.Booking.GetTicketByBookingCode)
		r.Post("/pdf", h.Pdf.Upload)
	})

	return r
}
