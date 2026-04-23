package controller

import (
	"gliranku/dto/request"
	"gliranku/service"
	"gliranku/utils"
	"net/http"

	"github.com/gin-gonic/gin"
)

type InformasiController struct {
	Service *service.InformasiService
}

func NewInformasiController(s *service.InformasiService) *InformasiController {
	return &InformasiController{Service: s}
}

// GET /api/v1/informasi
func (ctrl *InformasiController) Get(c *gin.Context) {
	result, err := ctrl.Service.Get()
	if err != nil {
		utils.Error(c, http.StatusInternalServerError, err.Error())
		return
	}
	utils.Success(c, http.StatusOK, "Informasi Rumah Sakit berhasil diambil", result)
}

// PUT /api/v1/informasi
func (ctrl *InformasiController) Update(c *gin.Context) {
	var req request.InformasiRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ValidationError(c, "Data tidak valid", err.Error())
		return
	}

	result, err := ctrl.Service.Update(req)
	if err != nil {
		utils.Error(c, http.StatusInternalServerError, err.Error())
		return
	}
	utils.Success(c, http.StatusOK, "Informasi Rumah Sakit berhasil diperbarui", result)
}
