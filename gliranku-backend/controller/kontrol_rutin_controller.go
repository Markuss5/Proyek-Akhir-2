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

func (ctrl *KontrolRutinController) Create(c *gin.Context) {
	var req request.CreateKontrolRutinRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ValidationError(c, "Data tidak valid", err.Error())
		return
	}

	controlDate, err := time.Parse(time.RFC3339, req.ControlDate)
	if err != nil {
		utils.Error(c, http.StatusBadRequest, "Format tanggal tak valid. Gunakan ISO-8601")
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

func (ctrl *KontrolRutinController) GetByNIK(c *gin.Context) {
	nik := c.Param("nik")

	results, err := ctrl.Service.GetByNIK(nik)
	if err != nil {
		utils.Error(c, http.StatusInternalServerError, "Gagal mengambil data kontrol rutin")
		return
	}

	utils.Success(c, http.StatusOK, "Data kontrol rutin berhasil diambil", response.FromKontrolRutinList(results))
}

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

func (ctrl *KontrolRutinController) GetAll(c *gin.Context) {
	results, err := ctrl.Service.GetAll()
	if err != nil {
		utils.Error(c, http.StatusInternalServerError, "Gagal mengambil semua data kontrol rutin")
		return
	}

	utils.Success(c, http.StatusOK, "Semua data kontrol rutin berhasil diambil", response.FromKontrolRutinList(results))
}

func (ctrl *KontrolRutinController) Delete(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		utils.Error(c, http.StatusBadRequest, "ID harus berupa angka")
		return
	}

	err = ctrl.Service.Delete(id)
	if err != nil {
		utils.Error(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.Success(c, http.StatusOK, "Jadwal kontrol rutin berhasil dihapus", nil)
}