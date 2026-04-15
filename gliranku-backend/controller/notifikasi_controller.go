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

type NotifikasiController struct {
	Service *service.NotifikasiService
}

func NewNotifikasiController(s *service.NotifikasiService) *NotifikasiController {
	return &NotifikasiController{Service: s}
}

// POST /api/v1/notifikasi
func (ctrl *NotifikasiController) Create(c *gin.Context) {
	var req request.CreateNotifikasiRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ValidationError(c, "Data tidak valid", err.Error())
		return
	}

	scheduledDate, err := time.Parse("2006-01-02", req.ScheduledDate)
	if err != nil {
		utils.Error(c, http.StatusBadRequest, "Format tanggal tidak valid. Gunakan format YYYY-MM-DD")
		return
	}

	result, err := ctrl.Service.CreateNotifikasi(req.NIK, req.Message, scheduledDate)
	if err != nil {
		utils.Error(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.Success(c, http.StatusCreated, "Notifikasi berhasil dibuat", response.FromNotifikasi(*result))
}

// GET /api/v1/notifikasi/pasien/:nik
func (ctrl *NotifikasiController) GetByNIK(c *gin.Context) {
	nik := c.Param("nik")

	results, err := ctrl.Service.GetByNIK(nik)
	if err != nil {
		utils.Error(c, http.StatusInternalServerError, "Gagal mengambil data notifikasi")
		return
	}

	utils.Success(c, http.StatusOK, "Data notifikasi berhasil diambil", response.FromNotifikasiList(results))
}

// GET /api/v1/notifikasi/pending
func (ctrl *NotifikasiController) GetPending(c *gin.Context) {
	results, err := ctrl.Service.GetPending()
	if err != nil {
		utils.Error(c, http.StatusInternalServerError, "Gagal mengambil notifikasi pending")
		return
	}

	utils.Success(c, http.StatusOK, "Notifikasi pending berhasil diambil", response.FromNotifikasiList(results))
}

// PUT /api/v1/notifikasi/:id/mark-sent
func (ctrl *NotifikasiController) MarkAsSent(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		utils.Error(c, http.StatusBadRequest, "ID tidak valid")
		return
	}

	err = ctrl.Service.MarkAsSent(id)
	if err != nil {
		utils.Error(c, http.StatusInternalServerError, "Gagal menandai notifikasi sebagai terkirim")
		return
	}

	utils.Success(c, http.StatusOK, "Notifikasi berhasil ditandai sebagai terkirim", nil)
}

// POST /api/v1/notifikasi/process
func (ctrl *NotifikasiController) ProcessPending(c *gin.Context) {
	count, err := ctrl.Service.ProcessPendingNotifications()
	if err != nil {
		utils.Error(c, http.StatusInternalServerError, "Gagal memproses notifikasi pending")
		return
	}

	utils.Success(c, http.StatusOK, "Notifikasi pending berhasil diproses", gin.H{"processed_count": count})
}
