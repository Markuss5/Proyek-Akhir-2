package service

import (
	"fmt"
	"regexp"
	"strings"
	"time"

	"aplikasi_antrian/backend/internal/model"
	"aplikasi_antrian/backend/internal/repository"
)

var (
	nikRegex       = regexp.MustCompile(`^\d{16}$`)
	bpjsRegex      = regexp.MustCompile(`^\d{13}$`)
	queueCodeRegex = regexp.MustCompile(`^\d{12}$`)
	digitsRegex    = regexp.MustCompile(`\D`)
)

type ValidationService struct {
	repo *repository.ValidationRepository
}

func NewValidationService(repo *repository.ValidationRepository) *ValidationService {
	return &ValidationService{repo: repo}
}

func (s *ValidationService) ValidateNIK(input string) (model.NIKValidationResponse, error) {
	nik := digitsOnly(input)
	if !nikRegex.MatchString(nik) {
		return model.NIKValidationResponse{
			IsValid: false,
			Message: "NIK harus terdiri dari 16 digit angka.",
		}, nil
	}

	patient, err := s.repo.FindPatientByNIK(nik)
	if err != nil {
		return model.NIKValidationResponse{}, err
	}
	if patient == nil {
		return model.NIKValidationResponse{
			IsValid: false,
			Message: "NIK tidak ditemukan pada database.",
		}, nil
	}

	return model.NIKValidationResponse{
		IsValid:     true,
		Message:     "NIK valid.",
		PatientID:   patient.ID,
		QueueNumber: patient.QueueNumber,
		PatientName: patient.Name,
	}, nil
}

func (s *ValidationService) ValidateBPJSOrNIK(input string) (model.BPJSValidationResponse, error) {
	cleaned := digitsOnly(input)

	if nikRegex.MatchString(cleaned) {
		patient, err := s.repo.FindPatientByNIK(cleaned)
		if err != nil {
			return model.BPJSValidationResponse{}, err
		}
		if patient == nil {
			return model.BPJSValidationResponse{
				IsValid: false,
				Message: "NIK tidak ditemukan pada database.",
			}, nil
		}

		return model.BPJSValidationResponse{
			IsValid:     true,
			Message:     "NIK valid.",
			QueueNumber: patient.QueueNumber,
			PatientName: patient.Name,
		}, nil
	}

	if bpjsRegex.MatchString(cleaned) {
		patient, err := s.repo.FindPatientByBPJS(cleaned)
		if err != nil {
			return model.BPJSValidationResponse{}, err
		}
		if patient == nil {
			return model.BPJSValidationResponse{
				IsValid: false,
				Message: "Nomor BPJS tidak ditemukan pada database.",
			}, nil
		}

		return model.BPJSValidationResponse{
			IsValid:     true,
			Message:     "Nomor BPJS valid.",
			QueueNumber: patient.QueueNumber,
			PatientName: patient.Name,
		}, nil
	}

	return model.BPJSValidationResponse{
		IsValid: false,
		Message: "Input harus 16 digit NIK atau 13 digit nomor BPJS.",
	}, nil
}

func (s *ValidationService) ValidateQueueCode(input string) (model.QueueCodeValidationResponse, error) {
	queueCode := normalizeQueueCode(input)
	if !queueCodeRegex.MatchString(queueCode) {
		return model.QueueCodeValidationResponse{
			IsValid: false,
			Message: "Kode antrian harus 12 karakter (huruf/angka).",
		}, nil
	}

	record, err := s.repo.FindQueueByCode(queueCode)
	if err != nil {
		return model.QueueCodeValidationResponse{}, err
	}
	if record == nil {
		return model.QueueCodeValidationResponse{
			IsValid: false,
			Message: "Kode antrian tidak ditemukan pada database.",
		}, nil
	}

	return model.QueueCodeValidationResponse{
		IsValid: true,
		Message: "Kode antrian valid.",
		Data: &model.QueueVerificationData{
			QueueCode:    record.QueueCode,
			QueueNumber:  record.QueueNumber,
			PatientName:  record.PatientName,
			ClinicName:   record.ClinicName,
			DoctorName:   record.DoctorName,
			ScheduleInfo: record.ScheduleInfo,
			CreatedAt:    record.CreatedAt,
		},
	}, nil
}

func digitsOnly(input string) string {
	return digitsRegex.ReplaceAllString(input, "")
}

func normalizeQueueCode(input string) string {
	upper := strings.ToUpper(strings.TrimSpace(input))
	return regexp.MustCompile(`[^A-Z0-9]`).ReplaceAllString(upper, "")
}

func (s *ValidationService) CreatePharmacyQueue(patientID, patientName string) (model.PharmacyQueueResponse, error) {
	lastNumber, err := s.repo.GetLastPharmacyQueueNumber()
	if err != nil {
		return model.PharmacyQueueResponse{}, err
	}

	nextNumber := lastNumber + 1
	queueNumber := fmt.Sprintf("F%03d", nextNumber)

	// Generate pharmacy queue code
	pharmacyQueueCode := fmt.Sprintf("PHARM%03d", nextNumber)

	pharmacyQueue := &model.PharmacyQueue{
		ID:                fmt.Sprintf("PQ-%04d", nextNumber),
		PharmacyQueueCode: pharmacyQueueCode,
		QueueNumber:       queueNumber,
		PatientID:         patientID,
		ClinicName:        "FARMASI",
		DoctorName:        "-",
		ScheduleInfo:      "Pengambilan obat",
		CreatedAt:         time.Now(),
	}

	if err := s.repo.CreatePharmacyQueue(pharmacyQueue); err != nil {
		return model.PharmacyQueueResponse{}, err
	}

	return model.PharmacyQueueResponse{
		IsValid:     true,
		Message:     "Nomor antrian farmasi berhasil dibuat.",
		QueueNumber: queueNumber,
		PatientName: patientName,
		ClinicName:  "FARMASI",
	}, nil
}
