package services

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"regexp"
	"strings"

	"github.com/google/uuid"

	"giliran_ku_backend/models"
	"giliran_ku_backend/repo"
)

var (
	ErrNotFound  = errors.New("not found")
	ErrBadRequest = errors.New("bad request")
)

type QueueService struct {
	repo *repo.Repository
}

func NewQueueService(repo *repo.Repository) *QueueService {
	return &QueueService{repo: repo}
}

func (s *QueueService) GetPolis(ctx context.Context) ([]models.Poli, error) {
	return s.repo.GetActivePolis(ctx)
}

func (s *QueueService) GetDoctors(ctx context.Context, poliID string) ([]models.Doctor, error) {
	poliID = strings.TrimSpace(poliID)
	if poliID == "" {
		return nil, badRequest("poli_id wajib diisi")
	}
	return s.repo.GetDoctorsByPoli(ctx, poliID)
}

func (s *QueueService) ValidatePatient(ctx context.Context, value string) (models.Patient, error) {
	if !isNumeric(value) {
		return models.Patient{}, badRequest("NIK/No BPJS tidak valid")
	}

	patient, err := s.repo.FindPatientByNikOrBpjs(ctx, value)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return models.Patient{}, notFound("Pasien tidak ditemukan")
		}
		return models.Patient{}, err
	}

	return patient, nil
}

func (s *QueueService) CreateBpjsTicket(ctx context.Context, value string) (models.Ticket, error) {
	patient, err := s.ValidatePatient(ctx, value)
	if err != nil {
		return models.Ticket{}, err
	}

	referral, err := s.repo.GetBpjsReferralByNik(ctx, patient.Nik)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return models.Ticket{}, notFound("Rujukan BPJS belum tersedia")
		}
		return models.Ticket{}, err
	}

	poli, err := s.repo.GetPoliByID(ctx, referral.PoliID)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return models.Ticket{}, notFound("Poli tidak ditemukan")
		}
		return models.Ticket{}, err
	}

	doctor, err := s.repo.GetDoctorByID(ctx, referral.DoctorID)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return models.Ticket{}, notFound("Dokter tidak ditemukan")
		}
		return models.Ticket{}, err
	}

	if doctor.PoliID != poli.ID {
		return models.Ticket{}, badRequest("Dokter tidak sesuai dengan poli")
	}

	ticketID := newID("TKT")
	ticket, err := s.repo.CreateConsultationTicket(ctx, repo.CreateConsultationParams{
		TicketID:   ticketID,
		PoliID:     poli.ID,
		DoctorID:   doctor.ID,
		PatientNik: patient.Nik,
	})
	if err != nil {
		return models.Ticket{}, err
	}

	ticket.Type = "konsultasi-bpjs"
	return ticket, nil
}

func (s *QueueService) CreateGeneralTicket(
	ctx context.Context,
	nik string,
	poliID string,
	doctorID string,
) (models.Ticket, error) {
	if strings.TrimSpace(nik) == "" || strings.TrimSpace(poliID) == "" || strings.TrimSpace(doctorID) == "" {
		return models.Ticket{}, badRequest("nik, poli_id, dan doctor_id wajib diisi")
	}

	patient, err := s.ValidatePatient(ctx, nik)
	if err != nil {
		return models.Ticket{}, err
	}

	poli, err := s.repo.GetPoliByID(ctx, poliID)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return models.Ticket{}, notFound("Poli tidak ditemukan")
		}
		return models.Ticket{}, err
	}

	doctor, err := s.repo.GetDoctorByID(ctx, doctorID)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return models.Ticket{}, notFound("Dokter tidak ditemukan")
		}
		return models.Ticket{}, err
	}

	if doctor.PoliID != poli.ID {
		return models.Ticket{}, badRequest("Dokter tidak sesuai dengan poli")
	}

	ticketID := newID("TKT")
	ticket, err := s.repo.CreateConsultationTicket(ctx, repo.CreateConsultationParams{
		TicketID:   ticketID,
		PoliID:     poli.ID,
		DoctorID:   doctor.ID,
		PatientNik: patient.Nik,
	})
	if err != nil {
		return models.Ticket{}, err
	}

	ticket.Type = "konsultasi-umum"
	return ticket, nil
}

func (s *QueueService) CreatePharmacyTicket(ctx context.Context, patientNik string) (models.Ticket, error) {
	var nikPtr *string
	if strings.TrimSpace(patientNik) != "" {
		_, err := s.ValidatePatient(ctx, patientNik)
		if err != nil {
			return models.Ticket{}, err
		}
		nikCopy := patientNik
		nikPtr = &nikCopy
	}

	ticketID := newID("APT")
	ticket, err := s.repo.CreatePharmacyTicket(ctx, ticketID, nikPtr)
	if err != nil {
		return models.Ticket{}, err
	}
	return ticket, nil
}

func (s *QueueService) GetTicketByBookingCode(ctx context.Context, code string) (models.Ticket, error) {
	if strings.TrimSpace(code) == "" {
		return models.Ticket{}, badRequest("kode booking wajib diisi")
	}

	ticket, err := s.repo.GetTicketByBookingCode(ctx, code)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return models.Ticket{}, notFound("Kode booking tidak ditemukan")
		}
		return models.Ticket{}, err
	}
	ticket.Type = "booking"
	return ticket, nil
}

func newID(prefix string) string {
	return fmt.Sprintf("%s-%s", prefix, uuid.NewString())
}

func isNumeric(value string) bool {
	re := regexp.MustCompile(`^\d{6,}$`)
	return re.MatchString(value)
}

func badRequest(message string) error {
	return fmt.Errorf("%w: %s", ErrBadRequest, message)
}

func notFound(message string) error {
	return fmt.Errorf("%w: %s", ErrNotFound, message)
}
