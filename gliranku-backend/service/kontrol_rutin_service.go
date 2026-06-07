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

func (s *KontrolRutinService) CreateKontrolRutin(nik string, controlDate time.Time, notes *string) (*models.KontrolRutin, error) {
	pasien, err := s.PasienRepo.FindByNIK(nik)
	if err != nil {
		return nil, fmt.Errorf("gagal mencari data pasien: %w", err)
	}
	if pasien == nil {
		return nil, fmt.Errorf("pasien dengan NIK %s tidak ditemukan", nik)
	}

	kr := &models.KontrolRutin{
		ControlDate: controlDate,
		Notes:       notes,
		NIK:         nik,
	}

	result, err := s.KontrolRutinRepo.Create(kr)
	if err != nil {
		return nil, fmt.Errorf("gagal membuat jadwal kontrol: %w", err)
	}

	reminderDays := []int{7, 3, 1}
	for _, daysBefore := range reminderDays {
		scheduledDate := controlDate.AddDate(0, 0, -daysBefore)

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
			fmt.Printf("Warning: gagal membuat notifikasi %d hari sebelum: %v\n", daysBefore, err)
		}
	}

	oneHourBefore := controlDate.Add(-1 * time.Hour)
	if oneHourBefore.After(time.Now()) {
		message := fmt.Sprintf(
			"Jadwal kontrol rutin Anda 1 jam lagi (pukul %s). Segera menuju RSUD Porsea.",
			controlDate.Format("15:04"),
		)

		notif := &models.Notifikasi{
			Message:       message,
			ScheduledDate: oneHourBefore,
			IsSent:        false,
			NIK:           nik,
		}

		_, err := s.NotifikasiRepo.Create(notif)
		if err != nil {
			fmt.Printf("Warning: gagal membuat notifikasi 1 jam sebelum: %v\n", err)
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