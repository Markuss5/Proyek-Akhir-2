package service

import (
	"fmt"
	"gliranku/models"
	"gliranku/repository"
	"time"
)

type NotifikasiService struct {
	NotifikasiRepo *repository.NotifikasiRepository
	PasienRepo     *repository.PasienRepository
}

func NewNotifikasiService(
	nRepo *repository.NotifikasiRepository,
	pRepo *repository.PasienRepository,
) *NotifikasiService {
	return &NotifikasiService{
		NotifikasiRepo: nRepo,
		PasienRepo:     pRepo,
	}
}

func (s *NotifikasiService) CreateNotifikasi(nik string, message string, scheduledDate time.Time) (*models.Notifikasi, error) {
	// Validate patient exists
	pasien, err := s.PasienRepo.FindByNIK(nik)
	if err != nil {
		return nil, fmt.Errorf("gagal mencari data pasien: %w", err)
	}
	if pasien == nil {
		return nil, fmt.Errorf("pasien dengan NIK %s tidak ditemukan", nik)
	}

	notif := &models.Notifikasi{
		Message:       message,
		ScheduledDate: scheduledDate,
		IsSent:        false,
		NIK:           nik,
	}

	return s.NotifikasiRepo.Create(notif)
}

func (s *NotifikasiService) GetByNIK(nik string) ([]models.Notifikasi, error) {
	return s.NotifikasiRepo.FindByNIK(nik)
}

func (s *NotifikasiService) GetPending() ([]models.Notifikasi, error) {
	return s.NotifikasiRepo.FindPending()
}

func (s *NotifikasiService) MarkAsSent(id int) error {
	return s.NotifikasiRepo.MarkAsSent(id)
}

// ProcessPendingNotifications finds all unsent notifications due today or earlier,
// marks them as sent, and returns the count. This is the hook point for FCM integration.
func (s *NotifikasiService) ProcessPendingNotifications() (int, error) {
	pending, err := s.NotifikasiRepo.FindPending()
	if err != nil {
		return 0, fmt.Errorf("gagal mengambil notifikasi pending: %w", err)
	}

	count := 0
	for _, n := range pending {
		// Future: send via FCM here
		err := s.NotifikasiRepo.MarkAsSent(n.NotificationID)
		if err != nil {
			fmt.Printf("Warning: gagal menandai notifikasi %d sebagai terkirim: %v\n", n.NotificationID, err)
			continue
		}
		count++
	}
	return count, nil
}

func (s *NotifikasiService) DeleteNotifikasi(id int) error {
	return s.NotifikasiRepo.Delete(id)
}
