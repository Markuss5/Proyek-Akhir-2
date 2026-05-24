package service

import (
	"fmt"
	"gliranku/dto/request"
	"gliranku/models"
	"gliranku/repository"
)

type DokterService struct {
	DokterRepo *repository.DokterRepository
}

func NewDokterService(repo *repository.DokterRepository) *DokterService {
	return &DokterService{DokterRepo: repo}
}

func (s *DokterService) Create(req request.DokterRequest) (*models.Dokter, error) {
	dokter := &models.Dokter{
		DoctorName:     req.DoctorName,
		Specialization: req.Specialization,
		PolyID:         req.PolyID,
		Phone:          req.Phone,
		Schedule:       req.Schedule,
		MaxKuotaNonJKN: req.MaxKuotaNonJKN,
		Senin:          req.Senin,
		Selasa:         req.Selasa,
		Rabu:           req.Rabu,
		Kamis:          req.Kamis,
		Jumat:          req.Jumat,
		Sabtu:          req.Sabtu,
		Minggu:         req.Minggu,
	}

	result, err := s.DokterRepo.Create(dokter)
	if err != nil {
		return nil, fmt.Errorf("gagal menambahkan dokter: %w", err)
	}
	return result, nil
}

func (s *DokterService) Update(id int, req request.DokterRequest) (*models.Dokter, error) {
	existing, err := s.DokterRepo.FindByID(id)
	if err != nil {
		return nil, fmt.Errorf("gagal mencari data dokter: %w", err)
	}
	if existing == nil {
		return nil, fmt.Errorf("dokter dengan ID %d tidak ditemukan", id)
	}

	existing.DoctorName = req.DoctorName
	existing.Specialization = req.Specialization
	existing.PolyID = req.PolyID
	existing.Phone = req.Phone
	existing.Schedule = req.Schedule
	existing.MaxKuotaNonJKN = req.MaxKuotaNonJKN
	existing.Senin = req.Senin
	existing.Selasa = req.Selasa
	existing.Rabu = req.Rabu
	existing.Kamis = req.Kamis
	existing.Jumat = req.Jumat
	existing.Sabtu = req.Sabtu
	existing.Minggu = req.Minggu

	result, err := s.DokterRepo.Update(existing)
	if err != nil {
		return nil, fmt.Errorf("gagal memperbarui dokter: %w", err)
	}
	return result, nil
}

func (s *DokterService) Delete(id int) error {
	existing, err := s.DokterRepo.FindByID(id)
	if err != nil {
		return fmt.Errorf("gagal mencari data dokter: %w", err)
	}
	if existing == nil {
		return fmt.Errorf("dokter dengan ID %d tidak ditemukan", id)
	}

	err = s.DokterRepo.Delete(id)
	if err != nil {
		return fmt.Errorf("gagal menghapus dokter: %w", err)
	}
	return nil
}