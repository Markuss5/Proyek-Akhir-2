package controller

import (
	"gliranku/repository"
	"gliranku/utils"
	"net/http"

	"github.com/gin-gonic/gin"
)

type PoliController struct {
	Repo *repository.PoliRepository
}

func NewPoliController(repo *repository.PoliRepository) *PoliController {
	return &PoliController{Repo: repo}
}

// GET /api/v1/poliklinik
func (ctrl *PoliController) GetAll(c *gin.Context) {
	results, err := ctrl.Repo.FindAll()
	if err != nil {
		utils.Error(c, http.StatusInternalServerError, "Gagal mengambil data poliklinik")
		return
	}
	utils.Success(c, http.StatusOK, "Data poliklinik berhasil diambil", results)
}
