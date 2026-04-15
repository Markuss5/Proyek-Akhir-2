package controller

import (
	"gliranku/dto/request"
	"gliranku/dto/response"
	"gliranku/service"
	"gliranku/utils"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
)

type KontrolRutinController struct {
	Service *service.KontrolRutinService
}

func NewKontrolRutinController(s *service.KontrolRutinService) *KontrolRutinController {
	return &KontrolRutinController{Service: s}
}

// POST /api/v1/kontrol-rutin
func (ctrl *KontrolRutinController) Create(c *gin.Context) {
	var req request.CreateKontrolRutinRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ValidationError(c, "Data tidak valid", err.Error())
		return
	}

	controlDate, err := time.Parse("2006-01-02", req.ControlDate)
	if err != nil {
		utils.Error(c, http.StatusBadRequest, "Format tanggal tidak valid. Gunakan format YYYY-MM-DD")
		return
	}

	var notes *string
	if req.Notes != "" {
		notes = &req.Notes
	}

	result, err := ctrl.Service.CreateKontrolRutin(req.NIK, controlDate, notes)
	if err != nil {
		utils.Error(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.Success(c, http.StatusCreated, "Jadwal kontrol rutin berhasil dibuat. Notifikasi pengingat telah dijadwalkan (H-7, H-3, H-1).", response.FromKontrolRutin(*result))
}

// GET /api/v1/kontrol-rutin/pasien/:nik
func (ctrl *KontrolRutinController) GetByNIK(c *gin.Context) {
	nik := c.Param("nik")

	results, err := ctrl.Service.GetByNIK(nik)
	if err != nil {
		utils.Error(c, http.StatusInternalServerError, "Gagal mengambil data kontrol rutin")
		return
	}

	utils.Success(c, http.StatusOK, "Data kontrol rutin berhasil diambil", response.FromKontrolRutinList(results))
}

// GET /api/v1/kontrol-rutin/upcoming?days=7
func (ctrl *KontrolRutinController) GetUpcoming(c *gin.Context) {
	daysStr := c.DefaultQuery("days", "7")
	days, err := strconv.Atoi(daysStr)
	if err != nil {
		utils.Error(c, http.StatusBadRequest, "Parameter 'days' harus berupa angka")
		return
	}

	results, err := ctrl.Service.GetUpcoming(days)
	if err != nil {
		utils.Error(c, http.StatusInternalServerError, "Gagal mengambil data kontrol mendatang")
		return
	}

	utils.Success(c, http.StatusOK, "Data kontrol mendatang berhasil diambil", response.FromKontrolRutinList(results))
}
