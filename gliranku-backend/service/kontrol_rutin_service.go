package service

import (
	"fmt"
	"gliranku/models"
	"gliranku/repository"
	"time"
)

type KontrolRutinService struct {
	KontrolRutinRepo *repository.KontrolRutinRepository
	NotifikasiRepo   *repository.NotifikasiRepository
	PasienRepo       *repository.PasienRepository
}

func NewKontrolRutinService(
	krRepo *repository.KontrolRutinRepository,
	nRepo *repository.NotifikasiRepository,
	pRepo *repository.PasienRepository,
) *KontrolRutinService {
	return &KontrolRutinService{
		KontrolRutinRepo: krRepo,
		NotifikasiRepo:   nRepo,
		PasienRepo:       pRepo,
	}
}

// CreateKontrolRutin creates a routine control and auto-generates 3 notifications:
// - 7 days before the control date
// - 3 days before the control date
// - 1 day before the control date
func (s *KontrolRutinService) CreateKontrolRutin(nik string, controlDate time.Time, notes *string) (*models.KontrolRutin, error) {
	// Validate patient exists
	pasien, err := s.PasienRepo.FindByNIK(nik)
	if err != nil {
		return nil, fmt.Errorf("gagal mencari data pasien: %w", err)
	}
	if pasien == nil {
		return nil, fmt.Errorf("pasien dengan NIK %s tidak ditemukan", nik)
	}

	// Create the kontrol rutin record
	kr := &models.KontrolRutin{
		ControlDate: controlDate,
		Notes:       notes,
		NIK:         nik,
	}

	result, err := s.KontrolRutinRepo.Create(kr)
	if err != nil {
		return nil, fmt.Errorf("gagal membuat jadwal kontrol: %w", err)
	}

	// Auto-generate 3 notifications at 7, 3, and 1 day(s) before
	reminderDays := []int{7, 3, 1}
	for _, daysBefore := range reminderDays {
		scheduledDate := controlDate.AddDate(0, 0, -daysBefore)

		// Only create notification if the scheduled date is today or in the future
		if scheduledDate.Before(time.Now().Truncate(24 * time.Hour)) {
			continue
		}

		message := fmt.Sprintf(
			"Pengingat: Jadwal kontrol rutin Anda %d hari lagi (tanggal %s). Jangan lupa untuk datang ke RSUD Porsea.",
			daysBefore,
			controlDate.Format("02 January 2006"),
		)

		notif := &models.Notifikasi{
			Message:       message,
			ScheduledDate: scheduledDate,
			IsSent:        false,
			NIK:           nik,
		}

		_, err := s.NotifikasiRepo.Create(notif)
		if err != nil {
			// Log but don't fail the main operation
			fmt.Printf("Warning: gagal membuat notifikasi %d hari sebelum: %v\n", daysBefore, err)
		}
	}

	return result, nil
}

func (s *KontrolRutinService) GetByNIK(nik string) ([]models.KontrolRutin, error) {
	return s.KontrolRutinRepo.FindByNIK(nik)
}

func (s *KontrolRutinService) GetUpcoming(days int) ([]models.KontrolRutin, error) {
	return s.KontrolRutinRepo.FindUpcoming(days)
}

func (s *KontrolRutinService) GetAll() ([]models.KontrolRutin, error) {
	return s.KontrolRutinRepo.FindAll()
}

func (s *KontrolRutinService) Delete(id int) error {
	return s.KontrolRutinRepo.Delete(id)
}
