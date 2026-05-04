package httpapi

import (
	"encoding/json"
	"log"
	"net/http"

	"aplikasi_antrian/backend/internal/model"
	"aplikasi_antrian/backend/internal/service"
)

type Handler struct {
	validationService *service.ValidationService
}

func NewHandler(validationService *service.ValidationService) *Handler {
	return &Handler{validationService: validationService}
}

func (h *Handler) RegisterRoutes(mux *http.ServeMux) {
	mux.HandleFunc("/health", h.withCORS(h.handleHealth))
	mux.HandleFunc("/api/v1/validate/nik", h.withCORS(h.handleValidateNIK))
	mux.HandleFunc("/api/v1/validate/bpjs-or-nik", h.withCORS(h.handleValidateBPJSOrNIK))
	mux.HandleFunc("/api/v1/validate/queue-code", h.withCORS(h.handleValidateQueueCode))
	mux.HandleFunc("/api/v1/pharmacy/queue", h.withCORS(h.handlePharmacyQueue))
}

func (h *Handler) handleHealth(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		writeMethodNotAllowed(w)
		return
	}

	writeJSON(w, http.StatusOK, map[string]string{
		"status":  "ok",
		"service": "aplikasi-antrian-backend",
	})
}

func (h *Handler) handleValidateNIK(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		writeMethodNotAllowed(w)
		return
	}

	var request model.NIKValidationRequest
	if err := decodeJSON(r, &request); err != nil {
		writeJSON(w, http.StatusBadRequest, map[string]interface{}{
			"isValid": false,
			"message": "Payload tidak valid.",
		})
		return
	}

	response, err := h.validationService.ValidateNIK(request.NIK)
	if err != nil {
		log.Printf("validate nik error: %v", err)
		writeJSON(w, http.StatusInternalServerError, map[string]interface{}{
			"isValid": false,
			"message": "Terjadi kesalahan pada server.",
		})
		return
	}

	writeJSON(w, http.StatusOK, response)
}

func (h *Handler) handleValidateBPJSOrNIK(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		writeMethodNotAllowed(w)
		return
	}

	var request model.BPJSOrNIKValidationRequest
	if err := decodeJSON(r, &request); err != nil {
		writeJSON(w, http.StatusBadRequest, map[string]interface{}{
			"isValid": false,
			"message": "Payload tidak valid.",
		})
		return
	}

	response, err := h.validationService.ValidateBPJSOrNIK(request.Input)
	if err != nil {
		log.Printf("validate bpjs/nik error: %v", err)
		writeJSON(w, http.StatusInternalServerError, map[string]interface{}{
			"isValid": false,
			"message": "Terjadi kesalahan pada server.",
		})
		return
	}

	writeJSON(w, http.StatusOK, response)
}

func (h *Handler) handleValidateQueueCode(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		writeMethodNotAllowed(w)
		return
	}

	var request model.QueueCodeValidationRequest
	if err := decodeJSON(r, &request); err != nil {
		writeJSON(w, http.StatusBadRequest, map[string]interface{}{
			"isValid": false,
			"message": "Payload tidak valid.",
		})
		return
	}

	response, err := h.validationService.ValidateQueueCode(request.QueueCode)
	if err != nil {
		log.Printf("validate queue code error: %v", err)
		writeJSON(w, http.StatusInternalServerError, map[string]interface{}{
			"isValid": false,
			"message": "Terjadi kesalahan pada server.",
		})
		return
	}

	writeJSON(w, http.StatusOK, response)
}

func (h *Handler) handlePharmacyQueue(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		writeMethodNotAllowed(w)
		return
	}

	var request struct {
		PatientID   string `json:"patientId"`
		PatientName string `json:"patientName"`
	}

	if err := decodeJSON(r, &request); err != nil {
		writeJSON(w, http.StatusBadRequest, map[string]interface{}{
			"isValid": false,
			"message": "Payload tidak valid.",
		})
		return
	}

	if request.PatientID == "" || request.PatientName == "" {
		writeJSON(w, http.StatusBadRequest, map[string]interface{}{
			"isValid": false,
			"message": "PatientID dan PatientName diperlukan.",
		})
		return
	}

	response, err := h.validationService.CreatePharmacyQueue(request.PatientID, request.PatientName)
	if err != nil {
		log.Printf("create pharmacy queue error: %v", err)
		writeJSON(w, http.StatusInternalServerError, map[string]interface{}{
			"isValid": false,
			"message": "Terjadi kesalahan pada server.",
		})
		return
	}

	writeJSON(w, http.StatusOK, response)
}

func (h *Handler) withCORS(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type")

		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusNoContent)
			return
		}

		next(w, r)
	}
}

func decodeJSON(r *http.Request, out interface{}) error {
	decoder := json.NewDecoder(r.Body)
	decoder.DisallowUnknownFields()
	return decoder.Decode(out)
}

func writeMethodNotAllowed(w http.ResponseWriter) {
	writeJSON(w, http.StatusMethodNotAllowed, map[string]interface{}{
		"isValid": false,
		"message": "Method tidak diizinkan.",
	})
}

func writeJSON(w http.ResponseWriter, statusCode int, payload interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(statusCode)
	_ = json.NewEncoder(w).Encode(payload)
}
