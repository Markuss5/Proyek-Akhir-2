package service

import (
	"fmt"
	"time"

	"gliranku/dto/request"
	"gliranku/dto/response"
	"gliranku/models"
	"gliranku/repository"
)

type AntrianService interface {
	GetPoliklinik() ([]response.LayananResponse, error)
	VerifyNIK(nik string) (*response.CekNIKResponse, error)
	CreateAntrian(req request.AntrianRequest) (*response.AntrianResponse, error)
	GetDashboardStats() (int, int, int, error)
	GetKunjunganStats(period string) ([]models.KunjunganStatPoli, error)
}

type antrianService struct {
	repo repository.AntrianRepository
}

func NewAntrianService(repo repository.AntrianRepository) AntrianService {
	return &antrianService{repo: repo}
}

func (s *antrianService) GetPoliklinik() ([]response.LayananResponse, error) {
	polis, err := s.repo.FetchPoliklinik()
	if err != nil {
		return nil, err
	}
	var result []response.LayananResponse
	for _, p := range polis {
		result = append(result, response.LayananResponse{
			ID:   p.PolyID,
			Nama: p.PolyName,
		})
	}
	return result, nil
}

func (s *antrianService) VerifyNIK(nik string) (*response.CekNIKResponse, error) {
	pasien, err := s.repo.CheckNIK(nik)
	if err != nil {
		return nil, err
	}
	if pasien == nil {
		return &response.CekNIKResponse{
			IsValid: false,
			Message: "Data pasien tidak ditemukan",
		}, nil
	}

	isBPJS := pasien.NoBPJS != nil && *pasien.NoBPJS != ""

	return &response.CekNIKResponse{
		IsValid:    true,
		IsBPJS:     isBPJS,
		NamaPasien: pasien.PatientName,
		Message:    "Data pasien ditemukan",
	}, nil
}

func (s *antrianService) CreateAntrian(req request.AntrianRequest) (*response.AntrianResponse, error) {
	tanggal := time.Now()

	lastNumber, err := s.repo.GetLastQueueNumber(req.PoliID, tanggal)
	if err != nil {
		return nil, fmt.Errorf("gagal mendapatkan nomor antrian: %w", err)
	}

	nomorUrut := lastNumber + 1
	noAntrian := fmt.Sprintf("A-%03d", nomorUrut)
	kodeBooking := repository.GenerateKodeBooking(tanggal, nomorUrut)

	pembayaran := "Umum"
	if req.IsPasienLama {
		pembayaran = "BPJS"
	}

	antrian := &models.Antrian{
		NoAntrian:    noAntrian,
		KodeBooking:  kodeBooking,
		NIK:          req.NIK,
		NamaPasien:   req.NamaPasien,
		Telepon:      req.Telepon,
		PoliID:       req.PoliID,
		Tanggal:      tanggal,
		WaktuMulai:   "09:00",
		WaktuSelesai: "12:00",
		Pembayaran:   pembayaran,
		IsPasienLama: req.IsPasienLama,
		Status:       "menunggu",
	}

	if err := s.repo.SaveAntrian(antrian); err != nil {
		return nil, fmt.Errorf("gagal menyimpan antrian: %w", err)
	}

	namaPoliklinik := fmt.Sprintf("Poli %d", req.PoliID)
	polis, _ := s.repo.FetchPoliklinik()
	for _, p := range polis {
		if p.PolyID == req.PoliID {
			namaPoliklinik = p.PolyName
			break
		}
	}

	return &response.AntrianResponse{
		NoAntrian:   noAntrian,
		KodeBooking: kodeBooking,
		Poliklinik:  namaPoliklinik,
		Dokter:      "dr. -",
		Tanggal:     tanggal.Format("02 Jan 2006"),
		Waktu:       "09:00 - 12:00",
		Pembayaran:  pembayaran,
	}, nil
}

func (s *antrianService) GetDashboardStats() (int, int, int, error) {
	return s.repo.GetDashboardStats()
}

func (s *antrianService) GetKunjunganStats(period string) ([]models.KunjunganStatPoli, error) {
	return s.repo.GetKunjunganStats(period)
}