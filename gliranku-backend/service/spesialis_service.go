package service

import (
	"fmt"
	"gliranku/models"
	"gliranku/repository"
)

type SpesialisService struct {
	Repo *repository.SpesialisRepository
}

func NewSpesialisService(repo *repository.SpesialisRepository) *SpesialisService {
	return &SpesialisService{Repo: repo}
}

func (s *SpesialisService) GetAll() ([]models.Spesialis, error) {
	return s.Repo.FindAll()
}

func (s *SpesialisService) GetByID(id int) (*models.Spesialis, error) {
	spesialis, err := s.Repo.FindByID(id)
	if err != nil {
		return nil, fmt.Errorf("gagal mengambil data spesialis: %w", err)
	}
	if spesialis == nil {
		return nil, fmt.Errorf("spesialis tidak ditemukan")
	}
	return spesialis, nil
}

func (s *SpesialisService) Create(spesialis models.Spesialis) (*models.Spesialis, error) {
	result, err := s.Repo.Create(&spesialis)
	if err != nil {
		return nil, fmt.Errorf("gagal menambahkan data spesialis: %w", err)
	}
	return result, nil
}

func (s *SpesialisService) Update(id int, spesialis models.Spesialis) (*models.Spesialis, error) {
	existing, err := s.GetByID(id)
	if err != nil {
		return nil, err
	}
	if existing == nil {
		return nil, fmt.Errorf("spesialis tidak ditemukan")
	}

	spesialis.ID = id
	result, err := s.Repo.Update(&spesialis)
	if err != nil {
		return nil, fmt.Errorf("gagal memperbarui data spesialis: %w", err)
	}
	return result, nil
}

func (s *SpesialisService) Delete(id int) error {
	existing, err := s.GetByID(id)
	if err != nil {
		return err
	}
	if existing == nil {
		return fmt.Errorf("spesialis tidak ditemukan")
	}

	err = s.Repo.Delete(id)
	if err != nil {
		return fmt.Errorf("gagal menghapus data spesialis: %w", err)
	}
	return nil
}