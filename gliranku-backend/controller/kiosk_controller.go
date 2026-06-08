package controller

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"regexp"
	"strings"

	"github.com/gin-gonic/gin"
	"gliranku/service"
)

var allowedFilenameChars = regexp.MustCompile(`[^a-zA-Z0-9\-_.]`)

func sanitizeFilename(name string) string {
	name = filepath.Base(name)
	name = allowedFilenameChars.ReplaceAllString(name, "_")
	if !strings.HasSuffix(strings.ToLower(name), ".pdf") {
		name = name + ".pdf"
	}
	return name
}

type KioskController interface {
	CreatePharmacyTicket(c *gin.Context)
	GetBooking(c *gin.Context)
	UploadPDF(c *gin.Context)
	CreateBpjsTicket(c *gin.Context)
}

type kioskController struct {
	antrianService service.AntrianService
}

func NewKioskController(antrianService service.AntrianService) KioskController {
	return &kioskController{antrianService: antrianService}
}

func (ctrl *kioskController) CreatePharmacyTicket(c *gin.Context) {
	ticket, err := ctrl.antrianService.CreatePharmacyTicket()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membuat tiket farmasi"})
		return
	}
	c.JSON(http.StatusCreated, gin.H{"data": ticket})
}

func (ctrl *kioskController) GetBooking(c *gin.Context) {
	code := c.Param("code")
	if code == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Kode booking diperlukan"})
		return
	}

	ticket, err := ctrl.antrianService.GetTicketByBookingCode(code)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	if ticket == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Kode booking tidak ditemukan"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": ticket})
}

func (ctrl *kioskController) UploadPDF(c *gin.Context) {
	file, err := c.FormFile("pdf")
	if err != nil {
		file, err = c.FormFile("file")
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "File PDF tidak ditemukan dalam request"})
			return
		}
	}

	const maxUploadSize = 5 << 20
	if file.Size > maxUploadSize {
		c.JSON(http.StatusRequestEntityTooLarge, gin.H{"error": "Ukuran file melebihi batas maksimal 5MB"})
		return
	}

	src, err := file.Open()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membaca file upload"})
		return
	}
	defer src.Close()

	magic := make([]byte, 4)
	if _, err := src.Read(magic); err == nil {
		if string(magic) != "%PDF" {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Hanya file PDF yang diizinkan"})
			return
		}
	}
	if seeker, ok := src.(interface{ Seek(int64, int) (int64, error) }); ok {
		seeker.Seek(0, 0)
	}

	filename := c.PostForm("filename")
	if filename == "" {
		filename = c.PostForm("ticket_id")
	}
	if filename == "" {
		filename = file.Filename
	} else {
		filename = fmt.Sprintf("%s.pdf", filename)
	}
	filename = sanitizeFilename(filename)

	saveDir := "queue_pdfs"
	if err := os.MkdirAll(saveDir, os.ModePerm); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membuat folder penyimpanan"})
		return
	}

	savePath := filepath.Join(saveDir, filename)
	if !strings.HasPrefix(filepath.Clean(savePath), filepath.Clean(saveDir)) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Nama file tidak valid"})
		return
	}

	out, err := os.Create(savePath)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan file"})
		return
	}
	defer out.Close()

	if _, err := io.Copy(out, src); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan isi file"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "File PDF berhasil diunggah", "path": savePath})
}

func (ctrl *kioskController) CreateBpjsTicket(c *gin.Context) {
	var req struct {
		NikOrBpjs string `json:"nik_or_bpjs"`
	}
	if err := c.ShouldBindJSON(&req); err != nil || req.NikOrBpjs == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "nik_or_bpjs wajib diisi"})
		return
	}

	result, err := ctrl.antrianService.CreateBpjsTicket(req.NikOrBpjs)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"data": result})
}