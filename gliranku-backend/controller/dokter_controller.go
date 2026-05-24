package controller

import (
	"gliranku/dto/request"
	"gliranku/repository"
	"gliranku/service"
	"gliranku/utils"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
)

type DokterController struct {
	Repo    *repository.DokterRepository
	Service *service.DokterService
}

func NewDokterController(repo *repository.DokterRepository, svc *service.DokterService) *DokterController {
	return &DokterController{Repo: repo, Service: svc}
}

func (ctrl *DokterController) GetByPoly(c *gin.Context) {
	polyIDStr := c.Query("poly_id")
	if polyIDStr == "" {
		polyIDStr = c.Param("poly_id")
	}
	if polyIDStr == "" {
		results, err := ctrl.Repo.FindAll()
		if err != nil {
			utils.Error(c, http.StatusInternalServerError, "Gagal mengambil data dokter")
			return
		}
		utils.Success(c, http.StatusOK, "Data dokter berhasil diambil", results)
		return
	}

	polyID, err := strconv.Atoi(polyIDStr)
	if err != nil {
		utils.Error(c, http.StatusBadRequest, "Parameter poly_id harus berupa angka")
		return
	}

	tanggal := c.Query("tanggal")
	if tanggal == "" {
		tanggal = time.Now().Format("2006-01-02")
	}

	results, err := ctrl.Repo.FindByPolyID(polyID, tanggal)
	if err != nil {
		utils.Error(c, http.StatusInternalServerError, "Gagal mengambil data dokter")
		return
	}
	utils.Success(c, http.StatusOK, "Data dokter berhasil diambil", results)
}

func (ctrl *DokterController) Create(c *gin.Context) {
	var req request.DokterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ValidationError(c, "Data tidak valid", err.Error())
		return
	}

	result, err := ctrl.Service.Create(req)
	if err != nil {
		utils.Error(c, http.StatusBadRequest, err.Error())
		return
	}
	utils.Success(c, http.StatusCreated, "Dokter berhasil ditambahkan", result)
}

func (ctrl *DokterController) Update(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		utils.Error(c, http.StatusBadRequest, "ID tidak valid")
		return
	}

	var req request.DokterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ValidationError(c, "Data tidak valid", err.Error())
		return
	}

	result, err := ctrl.Service.Update(id, req)
	if err != nil {
		utils.Error(c, http.StatusBadRequest, err.Error())
		return
	}
	utils.Success(c, http.StatusOK, "Dokter berhasil diperbarui", result)
}

func (ctrl *DokterController) Delete(c *gin.Context) {
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
	utils.Success(c, http.StatusOK, "Dokter berhasil dihapus", nil)
}
