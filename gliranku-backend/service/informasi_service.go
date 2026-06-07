package service

import (
	"fmt"
	"gliranku/dto/request"
	"gliranku/models"
	"gliranku/repository"
)

type InformasiService struct {
	InformasiRepo *repository.InformasiRepository
}

func NewInformasiService(repo *repository.InformasiRepository) *InformasiService {
	return &InformasiService{InformasiRepo: repo}
}

func (s *InformasiService) Get() (*models.Informasi, error) {
	info, err := s.InformasiRepo.Get()
	if err != nil {
		return nil, fmt.Errorf("gagal mengambil informasi rumah sakit: %w", err)
	}
	if info == nil {
		return nil, fmt.Errorf("informasi rumah sakit belum diatur")
	}
	return info, nil
}

func (s *InformasiService) Update(req request.InformasiRequest) (*models.Informasi, error) {
	info := &models.Informasi{
		ID:          1,
		Name:        req.Name,
		Description: req.Description,
		Vision:      req.Vision,
		Mission:     req.Mission,
		OpHours:     req.OpHours,
		Facilities:  req.Facilities,
		Address:     req.Address,
		Phone:       req.Phone,
		Email:       req.Email,
	}

	updated, err := s.InformasiRepo.Update(info)
	if err != nil {
		return nil, fmt.Errorf("gagal memperbarui informasi rumah sakit: %w", err)
	}
	return updated, nil
}