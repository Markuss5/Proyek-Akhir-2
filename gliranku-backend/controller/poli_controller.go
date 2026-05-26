package controller

import (
	"gliranku/dto/request"
	"gliranku/repository"
	"gliranku/service"
	"gliranku/utils"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

type PoliController struct {
	Repo    *repository.PoliRepository
	Service *service.PoliService
}

func NewPoliController(repo *repository.PoliRepository, svc *service.PoliService) *PoliController {
	return &PoliController{Repo: repo, Service: svc}
}

func (ctrl *PoliController) GetAll(c *gin.Context) {
	results, err := ctrl.Repo.FindAll()
	if err != nil {
		utils.Error(c, http.StatusInternalServerError, "Gagal mengambil data poliklinik")
		return
	}
	utils.Success(c, http.StatusOK, "Data poliklinik berhasil diambil", results)
}

func (ctrl *PoliController) Create(c *gin.Context) {
	var req request.PoliRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ValidationError(c, "Data tidak valid", err.Error())
		return
	}

	result, err := ctrl.Service.Create(req)
	if err != nil {
		utils.Error(c, http.StatusBadRequest, err.Error())
		return
	}
	utils.Success(c, http.StatusCreated, "Poliklinik berhasil ditambahkan", result)
}

func (ctrl *PoliController) Update(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		utils.Error(c, http.StatusBadRequest, "ID tidak valid")
		return
	}

	var req request.PoliRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ValidationError(c, "Data tidak valid", err.Error())
		return
	}

	result, err := ctrl.Service.Update(id, req)
	if err != nil {
		utils.Error(c, http.StatusBadRequest, err.Error())
		return
	}
	utils.Success(c, http.StatusOK, "Poliklinik berhasil diperbarui", result)
}

func (ctrl *PoliController) Delete(c *gin.Context) {
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
	utils.Success(c, http.StatusOK, "Poliklinik berhasil dihapus", nil)
}