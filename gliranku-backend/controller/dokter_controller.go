package controller

import (
	"gliranku/repository"
	"gliranku/utils"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

type DokterController struct {
	Repo *repository.DokterRepository
}

func NewDokterController(repo *repository.DokterRepository) *DokterController {
	return &DokterController{Repo: repo}
}

// GET /api/v1/dokter?poly_id=1
func (ctrl *DokterController) GetByPoly(c *gin.Context) {
	polyIDStr := c.Query("poly_id")
	if polyIDStr == "" {
		// Return all doctors if no poly_id filter
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

	results, err := ctrl.Repo.FindByPolyID(polyID)
	if err != nil {
		utils.Error(c, http.StatusInternalServerError, "Gagal mengambil data dokter")
		return
	}
	utils.Success(c, http.StatusOK, "Data dokter berhasil diambil", results)
}
