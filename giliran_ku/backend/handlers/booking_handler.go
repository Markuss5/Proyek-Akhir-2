package handlers

import (
	"net/http"

	"github.com/go-chi/chi/v5"

	"giliran_ku_backend/services"
)

type BookingHandler struct {
	service *services.QueueService
}

func (h *BookingHandler) GetTicketByBookingCode(w http.ResponseWriter, r *http.Request) {
	code := chi.URLParam(r, "code")
	if code == "" {
		writeError(w, http.StatusBadRequest, "kode booking wajib diisi")
		return
	}

	ticket, err := h.service.GetTicketByBookingCode(r.Context(), code)
	if err != nil {
		if handleServiceError(w, err) {
			return
		}
		writeError(w, http.StatusInternalServerError, "Gagal mengambil tiket booking")
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{"data": ticket})
}
