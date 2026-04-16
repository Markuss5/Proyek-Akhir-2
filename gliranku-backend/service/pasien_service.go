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

// Login validates NIK + name, returns patient data
// If patient doesn't exist, registers them automatically
func (s *PasienService) Login(nik string, name string) (*models.Pasien, error) {
	nik = strings.TrimSpace(nik)
	name = strings.TrimSpace(name)

	if len(nik) != 16 {
		return nil, fmt.Errorf("NIK harus 16 digit")
	}
	if name == "" {
		return nil, fmt.Errorf("nama tidak boleh kosong")
	}

	// Check if patient exists
	pasien, err := s.PasienRepo.FindByNIK(nik)
	if err != nil {
		return nil, fmt.Errorf("gagal mencari data pasien: %w", err)
	}

	if pasien != nil {
		// Validate name matches (case-insensitive)
		if !strings.EqualFold(pasien.PatientName, name) {
			return nil, fmt.Errorf("nama tidak sesuai dengan NIK yang terdaftar")
		}
		return pasien, nil
	}

	// Auto-register new patient
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

// GetProfile returns a patient's full profile
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

// UpdateProfile updates a patient's profile
func (s *PasienService) UpdateProfile(p *models.Pasien) (*models.Pasien, error) {
	existing, err := s.PasienRepo.FindByNIK(p.NIK)
	if err != nil {
		return nil, fmt.Errorf("gagal mencari data pasien: %w", err)
	}
	if existing == nil {
		return nil, fmt.Errorf("pasien dengan NIK %s tidak ditemukan", p.NIK)
	}

	result, err := s.PasienRepo.UpdateProfile(p)
	if err != nil {
		return nil, fmt.Errorf("gagal memperbarui profil: %w", err)
	}
	return result, nil
}
