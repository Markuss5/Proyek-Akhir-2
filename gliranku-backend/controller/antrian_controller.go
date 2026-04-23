package controller

import (
	"net/http"

	"gliranku/dto/request"
	"gliranku/service"

	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
)

type AntrianController struct {
	service  service.AntrianService
	validate *validator.Validate
}

func NewAntrianController(svc service.AntrianService) *AntrianController {
	return &AntrianController{
		service:  svc,
		validate: validator.New(),
	}
}

// GET /api/v1/antrian/layanan
// Sesuai sequence 1.1 → tampilkan jenis layanan
func (c *AntrianController) GetLayanan(ctx *gin.Context) {
	data, err := c.service.GetPoliklinik()
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Gagal memuat layanan",
		})
		return
	}
	ctx.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    data,
	})
}

// POST /api/v1/antrian/cek-nik
// Sesuai sequence 2A.1 → verifikasi NIK pasien lama
func (c *AntrianController) CekNIK(ctx *gin.Context) {
	var req request.CekNIKRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "Format request tidak valid",
		})
		return
	}

	result, err := c.service.VerifyNIK(req.NIK)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Gagal verifikasi NIK",
		})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    result,
	})
}

// POST /api/v1/antrian
// Sesuai sequence 4.1 → buat antrian baru
func (c *AntrianController) CreateAntrian(ctx *gin.Context) {
	var req request.AntrianRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "Format request tidak valid",
		})
		return
	}

	if err := c.validate.Struct(req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "Validasi gagal: " + err.Error(),
		})
		return
	}

	result, err := c.service.CreateAntrian(req)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": err.Error(),
		})
		return
	}

	ctx.JSON(http.StatusCreated, gin.H{
		"success": true,
		"message": "Antrian berhasil dibuat",
		"data":    result,
	})
}