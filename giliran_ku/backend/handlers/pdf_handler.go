package handlers

import (
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strings"
)

type PdfHandler struct {
	outputDir string
}

func NewPdfHandler(outputDir string) *PdfHandler {
	return &PdfHandler{outputDir: outputDir}
}

func (h *PdfHandler) Upload(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseMultipartForm(10 << 20); err != nil {
		writeError(w, http.StatusBadRequest, "Format upload tidak valid")
		return
	}

	file, header, err := r.FormFile("file")
	if err != nil {
		writeError(w, http.StatusBadRequest, "File PDF tidak ditemukan")
		return
	}
	defer file.Close()

	if err := os.MkdirAll(h.outputDir, 0o755); err != nil {
		writeError(w, http.StatusInternalServerError, "Gagal membuat folder output")
		return
	}

	filename := header.Filename
	if filename == "" {
		filename = "ticket.pdf"
	}
	filename = sanitizeFileName(filename)
	outputPath := filepath.Join(h.outputDir, filename)

	destination, err := os.Create(outputPath)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "Gagal menyimpan file")
		return
	}
	defer destination.Close()

	if _, err := io.Copy(destination, file); err != nil {
		writeError(w, http.StatusInternalServerError, "Gagal menulis file")
		return
	}

	writeJSON(w, http.StatusCreated, map[string]string{"path": outputPath})
}

func sanitizeFileName(name string) string {
	name = filepath.Base(name)
	name = strings.ReplaceAll(name, " ", "_")
	name = strings.ReplaceAll(name, "..", "_")
	return name
}
