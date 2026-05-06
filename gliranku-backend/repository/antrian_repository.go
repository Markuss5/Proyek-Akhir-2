package repository

import (
	"database/sql"
	"fmt"
	"time"

	"gliranku/models"
)

type AntrianRepository interface {
	FetchPoliklinik() ([]models.Poliklinik, error)
	CheckNIK(nik string) (*models.Pasien, error)
	GetLastQueueNumber(poliID int, tanggal time.Time) (int, error)
	SaveAntrian(antrian *models.Antrian) error
	GetDashboardStats() (int, int, int, error)
	GetKunjunganStats(period string) ([]models.KunjunganStatPoli, error)
}

type antrianRepository struct {
	db *sql.DB
}

func NewAntrianRepository(db *sql.DB) AntrianRepository {
	return &antrianRepository{db: db}
}

func (r *antrianRepository) FetchPoliklinik() ([]models.Poliklinik, error) {
	rows, err := r.db.Query(
		`SELECT "IdPoli", "NamaPoli", "KodePoli" FROM tbpoli ORDER BY "NamaPoli"`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var result []models.Poliklinik
	for rows.Next() {
		var p models.Poliklinik
		if err := rows.Scan(&p.PolyID, &p.PolyName, &p.KodePoli); err != nil {
			continue
		}
		p.IsActive = true
		result = append(result, p)
	}
	return result, nil
}

func (r *antrianRepository) CheckNIK(nik string) (*models.Pasien, error) {
	row := r.db.QueryRow(
		`SELECT nik, norm, patientname, phone, "noBPJS"
		 FROM pasien WHERE nik = $1`, nik)

	var p models.Pasien
	err := row.Scan(&p.NIK, &p.NoRM, &p.PatientName, &p.Phone, &p.NoBPJS)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &p, nil
}

func (r *antrianRepository) GetLastQueueNumber(poliID int, tanggal time.Time) (int, error) {
	row := r.db.QueryRow(`
		SELECT COALESCE(MAX(CAST(SUBSTRING(no_antrian FROM 3) AS INTEGER)), 0)
		FROM antrian
		WHERE poli_id = $1 AND DATE(tanggal) = $2
	`, poliID, tanggal.Format("2006-01-02"))

	var max int
	err := row.Scan(&max)
	return max, err
}

func (r *antrianRepository) SaveAntrian(a *models.Antrian) error {
	_, err := r.db.Exec(`
		INSERT INTO antrian
		(no_antrian, kode_booking, nik, nama_pasien, telepon, poli_id,
		 tanggal, waktu_mulai, waktu_selesai, pembayaran, is_pasien_lama, status)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)
	`,
		a.NoAntrian, a.KodeBooking, a.NIK, a.NamaPasien, a.Telepon,
		a.PoliID, a.Tanggal, a.WaktuMulai, a.WaktuSelesai,
		a.Pembayaran, a.IsPasienLama, a.Status,
	)
	return err
}

func GenerateKodeBooking(tanggal time.Time, urut int) string {
	return fmt.Sprintf("TB-%s-%03dXY", tanggal.Format("0601"), urut)
}

func (r *antrianRepository) GetDashboardStats() (int, int, int, error) {
	var pasienHariIni, dokterAktif, jumlahPoli int

	_ = r.db.QueryRow(
		`SELECT COUNT(*) FROM antrian WHERE tanggal >= CURRENT_DATE AND tanggal < CURRENT_DATE + INTERVAL '1 day'`,
	).Scan(&pasienHariIni)

	err := r.db.QueryRow(
		`SELECT COUNT(*) FROM category WHERE app = 1`,
	).Scan(&dokterAktif)
	if err != nil {
		return 0, 0, 0, err
	}

	err = r.db.QueryRow(
		`SELECT COUNT(*) FROM tbpoli`,
	).Scan(&jumlahPoli)
	if err != nil {
		return 0, 0, 0, err
	}

	return pasienHariIni, dokterAktif, jumlahPoli, nil
}

func (r *antrianRepository) GetKunjunganStats(period string) ([]models.KunjunganStatPoli, error) {
	var dateFilter string
	switch period {
	case "weekly":
		dateFilter = `a.tanggal >= CURRENT_DATE - INTERVAL '7 days'`
	case "monthly":
		dateFilter = `a.tanggal >= CURRENT_DATE - INTERVAL '30 days'`
	default:
		dateFilter = `a.tanggal >= CURRENT_DATE AND a.tanggal < CURRENT_DATE + INTERVAL '1 day'`
	}

	rows, err := r.db.Query(fmt.Sprintf(`
		SELECT p."IdPoli", p."NamaPoli", COUNT(a.id) AS jumlah
		FROM tbpoli p
		LEFT JOIN antrian a ON a.poli_id = p."IdPoli" AND %s
		GROUP BY p."IdPoli", p."NamaPoli"
		ORDER BY jumlah DESC
	`, dateFilter))
	if err != nil {
		fallbackRows, fbErr := r.db.Query(
			`SELECT "IdPoli", "NamaPoli" FROM tbpoli ORDER BY "NamaPoli"`)
		if fbErr != nil {
			return nil, fbErr
		}
		defer fallbackRows.Close()

		var result []models.KunjunganStatPoli
		for fallbackRows.Next() {
			var s models.KunjunganStatPoli
			if err := fallbackRows.Scan(&s.PolyID, &s.PolyName); err != nil {
				continue
			}
			s.Jumlah = 0
			result = append(result, s)
		}
		return result, nil
	}
	defer rows.Close()

	var result []models.KunjunganStatPoli
	for rows.Next() {
		var s models.KunjunganStatPoli
		if err := rows.Scan(&s.PolyID, &s.PolyName, &s.Jumlah); err != nil {
			continue
		}
		result = append(result, s)
	}
	return result, nil
}