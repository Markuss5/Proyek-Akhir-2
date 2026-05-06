package handlers

import (
	"net/http"

	"giliran_ku_backend/services"
)

type MasterHandler struct {
	service *services.QueueService
}

func (h *MasterHandler) ListPolis(w http.ResponseWriter, r *http.Request) {
	polis, err := h.service.GetPolis(r.Context())
	if err != nil {
		writeError(w, http.StatusInternalServerError, "Gagal mengambil data poli")
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{"data": polis})
}

func (h *MasterHandler) ListDoctors(w http.ResponseWriter, r *http.Request) {
	poliID := r.URL.Query().Get("poli_id")
	doctors, err := h.service.GetDoctors(r.Context(), poliID)
	if err != nil {
		if handleServiceError(w, err) {
			return
		}
		writeError(w, http.StatusInternalServerError, "Gagal mengambil data dokter")
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{"data": doctors})
}
