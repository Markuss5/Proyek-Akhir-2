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
	GetTicketByBookingCode(code string) (*response.AntrianResponse, error)
	CreatePharmacyTicket() (*models.TiketFarmasi, error)
	CreateBpjsTicket(nik string) (*response.AntrianResponse, error)
	GetRiwayatAntrian(nik string) ([]response.AntrianResponse, error)
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

	// Fetch poliklinik data to get the unique code (KodePoli)
	var polyName string
	var kodePoli string = "A" // Default prefix
	polis, _ := s.repo.FetchPoliklinik()
	for _, p := range polis {
		if p.PolyID == req.PoliID {
			polyName = p.PolyName
			if p.KodePoli != nil {
				kodePoli = *p.KodePoli
			}
			break
		}
	}

	lastNumber, err := s.repo.GetLastQueueNumber(req.PoliID, tanggal)
	if err != nil {
		return nil, fmt.Errorf("gagal mendapatkan nomor antrian: %w", err)
	}

	nomorUrut := lastNumber + 1
	noAntrian := fmt.Sprintf("%s-%03d", kodePoli, nomorUrut)
	kodeBooking := repository.GenerateKodeBooking(tanggal, kodePoli, nomorUrut)

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
		DokterID:     req.DokterID,
		Tanggal:      tanggal,
		WaktuMulai:   "09:00",
		WaktuSelesai: "12:00",
		Pembayaran:   pembayaran,
		IsPasienLama: req.IsPasienLama,
		Status:       "menunggu",
	}

	if err := s.repo.SaveAntrian(antrian); err != nil {
		fmt.Printf("Error SaveAntrian: %v\n", err)
		return nil, fmt.Errorf("gagal menyimpan antrian: %w", err)
	}

	// Reduce quota if doctor is selected
	if req.DokterID != nil {
		if err := s.repo.DecrementDoctorQuota(*req.DokterID); err != nil {
			fmt.Printf("Warning: Gagal mengurangi kuota dokter %d: %v\n", *req.DokterID, err)
		}
	}

	// Map to response
	dokterName := "-"
	if req.DokterID != nil {
		name, err := s.repo.GetDoctorNameByID(*req.DokterID)
		if err == nil {
			dokterName = name
		}
	}

	return &response.AntrianResponse{
		NoAntrian:   noAntrian,
		KodeBooking: kodeBooking,
		Poliklinik:  polyName,
		Dokter:      dokterName,
		Tanggal:     tanggal.Format("02-01-2006"),
		Waktu:       "09:00 - 12:00",
		Pembayaran:  pembayaran,
		Status:      "menunggu",
	}, nil
}

func (s *antrianService) GetDashboardStats() (int, int, int, error) {
	return s.repo.GetDashboardStats()
}

func (s *antrianService) GetKunjunganStats(period string) ([]models.KunjunganStatPoli, error) {
	return s.repo.GetKunjunganStats(period)
}

func (s *antrianService) GetTicketByBookingCode(code string) (*response.AntrianResponse, error) {
	a, err := s.repo.GetTicketByBookingCode(code)
	if err != nil {
		return nil, err
	}
	if a == nil {
		return nil, nil
	}
	
	namaPoliklinik := fmt.Sprintf("Poli %d", a.PoliID)
	polis, _ := s.repo.FetchPoliklinik()
	for _, p := range polis {
		if p.PolyID == a.PoliID {
			namaPoliklinik = p.PolyName
			break
		}
	}
	
	return &response.AntrianResponse{
		NoAntrian:   a.NoAntrian,
		KodeBooking: a.KodeBooking,
		Poliklinik:  namaPoliklinik,
		Dokter:      "dr. -",
		Tanggal:     a.Tanggal.Format("02 Jan 2006"),
		Waktu:       fmt.Sprintf("%s - %s", a.WaktuMulai, a.WaktuSelesai),
		Pembayaran:  a.Pembayaran,
	}, nil
}

func (s *antrianService) CreatePharmacyTicket() (*models.TiketFarmasi, error) {
	return s.repo.CreatePharmacyTicket()
}

func (s *antrianService) CreateBpjsTicket(nik string) (*response.AntrianResponse, error) {
	pasien, err := s.repo.CheckNIK(nik)
	if err != nil {
		return nil, fmt.Errorf("gagal memeriksa NIK: %w", err)
	}
	if pasien == nil {
		return nil, fmt.Errorf("pasien dengan NIK %s tidak ditemukan", nik)
	}

	referral, err := s.repo.GetBpjsReferralByNik(nik)
	if err != nil {
		return nil, fmt.Errorf("gagal mencari rujukan BPJS: %w", err)
	}
	if referral == nil {
		return nil, fmt.Errorf("rujukan BPJS untuk NIK %s belum tersedia", nik)
	}

	req := request.AntrianRequest{
		NIK:          nik,
		NamaPasien:   pasien.PatientName,
		Telepon:      "-",
		PoliID:       referral.PoliID,
		DokterID:     &referral.DoctorID,
		IsPasienLama: true,
	}

	if pasien.Phone != nil && *pasien.Phone != "" {
		req.Telepon = *pasien.Phone
	}

	return s.CreateAntrian(req)
}

func (s *antrianService) GetRiwayatAntrian(nik string) ([]response.AntrianResponse, error) {
	data, err := s.repo.GetRiwayatByNIK(nik)
	if err != nil {
		return nil, err
	}

	var results []response.AntrianResponse
	for _, item := range data {
		results = append(results, response.AntrianResponse{
			NoAntrian:   item.NoAntrian,
			KodeBooking: item.KodeBooking,
			Poliklinik:  item.Poliklinik,
			Dokter:      item.Dokter,
			Tanggal:     item.Tanggal.Format("02-01-2006"),
			Waktu:       fmt.Sprintf("%s - %s", item.WaktuMulai, item.WaktuSelesai),
			Pembayaran:  item.Pembayaran,
			Status:      item.Status,
		})
	}
	return results, nil
}