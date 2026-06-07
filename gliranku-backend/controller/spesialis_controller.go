package controller

import (
	"gliranku/models"
	"gliranku/service"
	"gliranku/utils"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

type SpesialisController struct {
	Service *service.SpesialisService
}

func NewSpesialisController(svc *service.SpesialisService) *SpesialisController {
	return &SpesialisController{Service: svc}
}

func (ctrl *SpesialisController) GetAll(c *gin.Context) {
	results, err := ctrl.Service.GetAll()
	if err != nil {
		utils.Error(c, http.StatusInternalServerError, "Gagal mengambil data spesialis")
		return
	}
	utils.Success(c, http.StatusOK, "Data spesialis berhasil diambil", results)
}

func (ctrl *SpesialisController) GetByID(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		utils.Error(c, http.StatusBadRequest, "ID tidak valid")
		return
	}

	result, err := ctrl.Service.GetByID(id)
	if err != nil {
		utils.Error(c, http.StatusNotFound, err.Error())
		return
	}
	utils.Success(c, http.StatusOK, "Data spesialis berhasil diambil", result)
}

func (ctrl *SpesialisController) Create(c *gin.Context) {
	var req models.Spesialis
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ValidationError(c, "Data tidak valid", err.Error())
		return
	}

	result, err := ctrl.Service.Create(req)
	if err != nil {
		utils.Error(c, http.StatusBadRequest, err.Error())
		return
	}
	utils.Success(c, http.StatusCreated, "Data spesialis berhasil ditambahkan", result)
}

func (ctrl *SpesialisController) Update(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		utils.Error(c, http.StatusBadRequest, "ID tidak valid")
		return
	}

	var req models.Spesialis
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ValidationError(c, "Data tidak valid", err.Error())
		return
	}

	result, err := ctrl.Service.Update(id, req)
	if err != nil {
		utils.Error(c, http.StatusBadRequest, err.Error())
		return
	}
	utils.Success(c, http.StatusOK, "Data spesialis berhasil diperbarui", result)
}

func (ctrl *SpesialisController) Delete(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		utils.Error(c, http.StatusBadRequest, "ID tidak valid")
		return
	}

	err = ctrl.Service.Delete(id)
	if err != nil {
		utils.Error(c, http.StatusBadRequest, err.Error())
		return
	}
	utils.Success(c, http.StatusOK, "Data spesialis berhasil dihapus", nil)
}