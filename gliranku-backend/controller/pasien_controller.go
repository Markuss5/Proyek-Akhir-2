package controller

import (
	"gliranku/dto/request"
	"gliranku/models"
	"gliranku/service"
	"gliranku/utils"
	"net/http"

	"github.com/gin-gonic/gin"
)

type PasienController struct {
	Service *service.PasienService
}

func NewPasienController(s *service.PasienService) *PasienController {
	return &PasienController{Service: s}
}

// POST /api/v1/pasien/login
func (ctrl *PasienController) Login(c *gin.Context) {
	var req request.LoginPasienRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ValidationError(c, "Data tidak valid", err.Error())
		return
	}

	result, err := ctrl.Service.Login(req.NIK, req.Name)
	if err != nil {
		utils.Error(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.Success(c, http.StatusOK, "Login berhasil", result)
}

// GET /api/v1/pasien/profile/:nik
func (ctrl *PasienController) GetProfile(c *gin.Context) {
	nik := c.Param("nik")

	result, err := ctrl.Service.GetProfile(nik)
	if err != nil {
		utils.Error(c, http.StatusNotFound, err.Error())
		return
	}

	utils.Success(c, http.StatusOK, "Profil pasien berhasil diambil", result)
}

// PUT /api/v1/pasien/profile
func (ctrl *PasienController) UpdateProfile(c *gin.Context) {
	var req request.UpdatePasienProfileRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ValidationError(c, "Data tidak valid", err.Error())
		return
	}

	pasien := &models.Pasien{
		NIK:           req.NIK,
		PatientName:   req.PatientName,
		Phone:         req.Phone,
		Email:         req.Email,
		NoBPJS:        req.NoBPJS,
		GolonganDarah: req.GolonganDarah,
		TanggalLahir:  req.TanggalLahir,
		Alamat:        req.Alamat,
		JenisKelamin:  req.JenisKelamin,
	}

	result, err := ctrl.Service.UpdateProfile(pasien)
	if err != nil {
		utils.Error(c, http.StatusBadRequest, err.Error())
		return
	}

	utils.Success(c, http.StatusOK, "Profil berhasil diperbarui", result)
}
