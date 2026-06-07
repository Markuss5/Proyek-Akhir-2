package service

import (
	"fmt"
	"gliranku/models"
	"gliranku/repository"
	"strings"
)

type PasienService struct {
	PasienRepo *repository.PasienRepository
}

func NewPasienService(repo *repository.PasienRepository) *PasienService {
	return &PasienService{PasienRepo: repo}
}

func (s *PasienService) Login(nik string, name string) (*models.Pasien, error) {
	nik = strings.TrimSpace(nik)
	name = strings.TrimSpace(name)

	if len(nik) != 16 {
		return nil, fmt.Errorf("NIK harus 16 terdiri dari digit")
	}
	if name == "" {
		return nil, fmt.Errorf("nama tidak boleh kosong")
	}

	pasien, err := s.PasienRepo.FindByNIK(nik)
	if err != nil {
		return nil, fmt.Errorf("gagal mencari data pasien: %w", err)
	}

	if pasien != nil {
		if !strings.EqualFold(pasien.PatientName, name) {
			return nil, fmt.Errorf("nama tidak sesuai dengan NIK yang terdaftar")
		}
		return pasien, nil
	}

	pasienByName, err := s.PasienRepo.FindByNameCaseInsensitive(name)
	if err != nil {
		return nil, fmt.Errorf("gagal memeriksa nama pasien: %w", err)
	}
	if pasienByName != nil {
		return nil, fmt.Errorf("nama sudah terdaftar dengan NIK yang berbeda")
	}

	newPasien := &models.Pasien{
		NIK:         nik,
		PatientName: name,
	}

	result, err := s.PasienRepo.Register(newPasien)
	if err != nil {
		return nil, fmt.Errorf("gagal mendaftarkan pasien: %w", err)
	}

	return result, nil
}

func (s *PasienService) GetProfile(nik string) (*models.Pasien, error) {
	pasien, err := s.PasienRepo.FindByNIK(nik)
	if err != nil {
		return nil, fmt.Errorf("gagal mengambil profil: %w", err)
	}
	if pasien == nil {
		return nil, fmt.Errorf("pasien dengan NIK %s tidak ditemukan", nik)
	}
	return pasien, nil
}

func (s *PasienService) UpdateProfile(p *models.Pasien) (*models.Pasien, error) {
	existing, err := s.PasienRepo.FindByNIK(p.NIK)
	if err != nil {
		return nil, fmt.Errorf("gagal mencari data pasien: %w", err)
	}
	if existing == nil {
		return nil, fmt.Errorf("pasien dengan NIK %s tidak ditemukan", p.NIK)
	}

	if p.PatientName != "" && !strings.EqualFold(existing.PatientName, p.PatientName) {
		pasienByName, err := s.PasienRepo.FindByNameCaseInsensitive(p.PatientName)
		if err != nil {
			return nil, fmt.Errorf("gagal memeriksa ketersediaan nama: %w", err)
		}
		if pasienByName != nil && pasienByName.NIK != p.NIK {
			return nil, fmt.Errorf("nama sudah digunakan oleh pasien lain")
		}
	}

	result, err := s.PasienRepo.UpdateProfile(p)
	if err != nil {
		return nil, fmt.Errorf("gagal memperbarui profil: %w", err)
	}
	return result, nil
}