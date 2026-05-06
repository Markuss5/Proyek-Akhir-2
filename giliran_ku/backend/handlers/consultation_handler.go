package handlers

import (
	"errors"
	"log"
	"net/http"

	"giliran_ku_backend/services"
)

type ConsultationHandler struct {
	service *services.QueueService
}

type validateRequest struct {
	NikOrBpjs string `json:"nik_or_bpjs"`
}

type generalRequest struct {
	Nik      string `json:"nik"`
	PoliID   string `json:"poli_id"`
	DoctorID string `json:"doctor_id"`
}

func (h *ConsultationHandler) ValidatePatient(w http.ResponseWriter, r *http.Request) {
	var req validateRequest
	if err := readJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "Format JSON tidak valid")
		return
	}

	patient, err := h.service.ValidatePatient(r.Context(), req.NikOrBpjs)
	if err != nil {
		if handleServiceError(w, err) {
			return
		}
		writeError(w, http.StatusInternalServerError, "Gagal validasi pasien")
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{"data": patient})
}

func (h *ConsultationHandler) CreateBpjsTicket(w http.ResponseWriter, r *http.Request) {
	var req validateRequest
	if err := readJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "Format JSON tidak valid")
		return
	}

	if req.NikOrBpjs == "" {
		writeError(w, http.StatusBadRequest, "nik_or_bpjs wajib diisi")
		return
	}

	ticket, err := h.service.CreateBpjsTicket(r.Context(), req.NikOrBpjs)
	if err != nil {
		if handleServiceError(w, err) {
			return
		}
		log.Printf("create bpjs ticket error: %v", err)
		writeError(w, http.StatusInternalServerError, "Gagal membuat tiket BPJS")
		return
	}

	writeJSON(w, http.StatusCreated, map[string]any{"data": ticket})
}

func (h *ConsultationHandler) CreateGeneralTicket(w http.ResponseWriter, r *http.Request) {
	var req generalRequest
	if err := readJSON(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "Format JSON tidak valid")
		return
	}

	if req.Nik == "" || req.PoliID == "" || req.DoctorID == "" {
		writeError(w, http.StatusBadRequest, "nik, poli_id, dan doctor_id wajib diisi")
		return
	}

	ticket, err := h.service.CreateGeneralTicket(r.Context(), req.Nik, req.PoliID, req.DoctorID)
	if err != nil {
		if handleServiceError(w, err) {
			return
		}
		log.Printf("create general ticket error: %v", err)
		writeError(w, http.StatusInternalServerError, "Gagal membuat tiket umum")
		return
	}

	writeJSON(w, http.StatusCreated, map[string]any{"data": ticket})
}

func handleServiceError(w http.ResponseWriter, err error) bool {
	if errors.Is(err, services.ErrBadRequest) {
		writeError(w, http.StatusBadRequest, err.Error())
		return true
	}
	if errors.Is(err, services.ErrNotFound) {
		writeError(w, http.StatusNotFound, err.Error())
		return true
	}
	return false
}
