package handlers

import (
	"errors"
	"io"
	"net/http"

	"giliran_ku_backend/services"
)

type PharmacyHandler struct {
	service *services.QueueService
}

type pharmacyRequest struct {
	PatientNik string `json:"patient_nik"`
}

func (h *PharmacyHandler) CreatePharmacyTicket(w http.ResponseWriter, r *http.Request) {
	var req pharmacyRequest
	if err := readJSON(r, &req); err != nil {
		if !errors.Is(err, io.EOF) {
			writeError(w, http.StatusBadRequest, "Format JSON tidak valid")
			return
		}
	}

	ticket, err := h.service.CreatePharmacyTicket(r.Context(), req.PatientNik)
	if err != nil {
		if handleServiceError(w, err) {
			return
		}
		writeError(w, http.StatusInternalServerError, "Gagal membuat tiket farmasi")
		return
	}

	writeJSON(w, http.StatusCreated, map[string]any{"data": ticket})
}
