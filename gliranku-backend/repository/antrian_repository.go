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
}

type antrianRepository struct {
	db *sql.DB
}

func NewAntrianRepository(db *sql.DB) AntrianRepository {
	return &antrianRepository{db: db}
}

// 1.1.1.1 - SELECT * FROM poliklinik
func (r *antrianRepository) FetchPoliklinik() ([]models.Poliklinik, error) {
	rows, err := r.db.Query(
		`SELECT poly_id, poly_name, COALESCE(description, ''), is_active 
		 FROM poliklinik WHERE is_active = true ORDER BY poly_name`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var result []models.Poliklinik
	for rows.Next() {
		var p models.Poliklinik
		var desc string
		if err := rows.Scan(&p.PolyID, &p.PolyName, &desc, &p.IsActive); err != nil {
			continue
		}
		p.Description = &desc
		result = append(result, p)
	}
	return result, nil
}

// 2A.2.2 - SELECT pasien WHERE nik=?
func (r *antrianRepository) CheckNIK(nik string) (*models.Pasien, error) {
	row := r.db.QueryRow(
		`SELECT nik, no_rm, patient_name, phone, no_bpjs 
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

// 4.2.3 - SELECT MAX(no_antrian) → nomor terakhir
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

// 4.3.1 - INSERT INTO antrian
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