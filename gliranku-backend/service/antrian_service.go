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
}

type antrianService struct {
	repo repository.AntrianRepository
}

func NewAntrianService(repo repository.AntrianRepository) AntrianService {
	return &antrianService{repo: repo}
}

// 1.1.1 - GetJenisLayanan → SELECT * FROM poliklinik
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

// 2A.2 - VerifyNIK → SELECT pasien WHERE nik=?
// → 2A.2.5 Validasi Kepesertaan BPJS
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

	// 2A.2.5 - Validasi Kepesertaan BPJS
	isBPJS := pasien.NoBPJS != nil && *pasien.NoBPJS != ""

	return &response.CekNIKResponse{
		IsValid:    true,
		IsBPJS:     isBPJS,
		NamaPasien: pasien.PatientName,
		Message:    "Data pasien ditemukan",
	}, nil
}

// 4.2.1 - CreateAntrian
// → 4.2.2 GetLastQueueNumber → SELECT MAX(no_antrian)
// → 4.2.6 Generate nomor baru (terakhir + 1)
// → 4.3.1 SaveAntrian → INSERT INTO antrian
func (s *antrianService) CreateAntrian(req request.AntrianRequest) (*response.AntrianResponse, error) {
	tanggal := time.Now()

	// 4.2.3 - SELECT MAX(no_antrian)
	lastNumber, err := s.repo.GetLastQueueNumber(req.PoliID, tanggal)
	if err != nil {
		return nil, fmt.Errorf("gagal mendapatkan nomor antrian: %w", err)
	}

	// 4.2.6 - Generate nomor baru (nomor = terakhir + 1)
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

	// 4.3.1 - INSERT INTO antrian
	if err := s.repo.SaveAntrian(antrian); err != nil {
		return nil, fmt.Errorf("gagal menyimpan antrian: %w", err)
	}

	// Ambil nama poli untuk response
	namaPoliklinik := fmt.Sprintf("Poli %d", req.PoliID)
	polis, _ := s.repo.FetchPoliklinik()
	for _, p := range polis {
		if p.PolyID == req.PoliID {
			namaPoliklinik = p.PolyName
			break
		}
	}

	// 4.4 - Data antrian + kode booking
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