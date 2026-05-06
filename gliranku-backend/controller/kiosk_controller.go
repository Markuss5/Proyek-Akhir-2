package controller

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"

	"github.com/gin-gonic/gin"
	"gliranku/service"
)

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
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mencari kode booking"})
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
		c.JSON(http.StatusBadRequest, gin.H{"error": "File PDF tidak ditemukan dalam request"})
		return
	}

	filename := c.PostForm("filename")
	if filename == "" {
		filename = file.Filename
	} else {
		filename = fmt.Sprintf("%s.pdf", filename)
	}

	saveDir := "queue_pdfs"
	if err := os.MkdirAll(saveDir, os.ModePerm); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membuat folder penyimpanan"})
		return
	}

	savePath := filepath.Join(saveDir, filename)
	src, err := file.Open()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membaca file upload"})
		return
	}
	defer src.Close()

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