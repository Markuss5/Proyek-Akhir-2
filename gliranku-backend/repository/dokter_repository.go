package repository

import (
	"database/sql"
	"gliranku/models"
)

type DokterRepository struct {
	DB *sql.DB
}

func NewDokterRepository(db *sql.DB) *DokterRepository {
	return &DokterRepository{DB: db}
}

func (r *DokterRepository) FindByPolyID(polyID int, tanggal string) ([]models.Dokter, error) {
	query := `
		SELECT c.id as category_id, c.namadokter, c."IdPoli", p."NamaPoli", d."NoTelp", d."Spesialisasi", c.options as schedule,
		       COALESCE(c.senin,''), COALESCE(c.selasa,''), COALESCE(c.rabu,''),
		       COALESCE(c.kamis,''), COALESCE(c.jumat,''), COALESCE(c.sabtu,''), COALESCE(c.minggu,''),
		       (COALESCE(c."MaxKuotaNonJKN", 30) - (SELECT COUNT(*) FROM antrian a WHERE a.dokter_id = c.id AND DATE(a.tanggal) = $2 AND status != 'dibatalkan')), COALESCE(c."MaxKuotaNonJKN", 30)
		FROM category c
		JOIN tbpoli p ON c."IdPoli" = p."IdPoli"
		LEFT JOIN tbdaftardokter d ON c."IdDokter" = d."IdDokter"
		WHERE c."IdPoli" = $1 AND c.app = 1
		ORDER BY c.namadokter ASC
	`

	rows, err := r.DB.Query(query, polyID, tanggal)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []models.Dokter
	for rows.Next() {
		var d models.Dokter
		var spesialisasi sql.NullInt64
		var telp sql.NullString
		var schedule sql.NullString

		err := rows.Scan(&d.DoctorID, &d.DoctorName, &d.PolyID, &d.PolyName, &telp, &spesialisasi, &schedule,
			&d.Senin, &d.Selasa, &d.Rabu, &d.Kamis, &d.Jumat, &d.Sabtu, &d.Minggu, &d.KuotaNonJKN, &d.MaxKuotaNonJKN)
		if err != nil {
			return nil, err
		}
		if telp.Valid {
			d.Phone = telp.String
		}
		if schedule.Valid {
			d.Schedule = schedule.String
		}
		d.Status = true
		results = append(results, d)
	}
	return results, nil
}

func (r *DokterRepository) FindAll() ([]models.Dokter, error) {
	query := `
		SELECT c.id as category_id, c.namadokter, c."IdPoli", p."NamaPoli", d."NoTelp", d."Spesialisasi", c.options as schedule,
		       COALESCE(c.senin,''), COALESCE(c.selasa,''), COALESCE(c.rabu,''),
		       COALESCE(c.kamis,''), COALESCE(c.jumat,''), COALESCE(c.sabtu,''), COALESCE(c.minggu,''),
		       COALESCE(c."KuotaNonJKN", 0), COALESCE(c."MaxKuotaNonJKN", 30)
		FROM category c
		JOIN tbpoli p ON c."IdPoli" = p."IdPoli"
		LEFT JOIN tbdaftardokter d ON c."IdDokter" = d."IdDokter"
		WHERE c.app = 1
		ORDER BY c.namadokter ASC
	`

	rows, err := r.DB.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []models.Dokter
	for rows.Next() {
		var d models.Dokter
		var spesialisasi sql.NullInt64
		var telp sql.NullString
		var schedule sql.NullString

		err := rows.Scan(&d.DoctorID, &d.DoctorName, &d.PolyID, &d.PolyName, &telp, &spesialisasi, &schedule,
			&d.Senin, &d.Selasa, &d.Rabu, &d.Kamis, &d.Jumat, &d.Sabtu, &d.Minggu, &d.KuotaNonJKN, &d.MaxKuotaNonJKN)
		if err != nil {
			return nil, err
		}
		if telp.Valid {
			d.Phone = telp.String
		}
		if schedule.Valid {
			d.Schedule = schedule.String
		}
		d.Status = true
		results = append(results, d)
	}
	return results, nil
}

func (r *DokterRepository) FindByID(id int) (*models.Dokter, error) {
	query := `
		SELECT c.id as category_id, c.namadokter, c."IdPoli", p."NamaPoli", d."NoTelp", d."Spesialisasi", c.options as schedule,
		       COALESCE(c.senin,''), COALESCE(c.selasa,''), COALESCE(c.rabu,''),
		       COALESCE(c.kamis,''), COALESCE(c.jumat,''), COALESCE(c.sabtu,''), COALESCE(c.minggu,''),
		       COALESCE(c."KuotaNonJKN", 0), COALESCE(c."MaxKuotaNonJKN", 30)
		FROM category c
		JOIN tbpoli p ON c."IdPoli" = p."IdPoli"
		LEFT JOIN tbdaftardokter d ON c."IdDokter" = d."IdDokter"
		WHERE c.id = $1 AND c.app = 1
	`

	var d models.Dokter
	var spesialisasi sql.NullInt64
	var telp sql.NullString
	var schedule sql.NullString

	err := r.DB.QueryRow(query, id).Scan(&d.DoctorID, &d.DoctorName, &d.PolyID, &d.PolyName, &telp, &spesialisasi, &schedule,
		&d.Senin, &d.Selasa, &d.Rabu, &d.Kamis, &d.Jumat, &d.Sabtu, &d.Minggu, &d.KuotaNonJKN, &d.MaxKuotaNonJKN)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	if telp.Valid {
		d.Phone = telp.String
	}
	if schedule.Valid {
		d.Schedule = schedule.String
	}
	d.Status = true
	return &d, nil
}

func (r *DokterRepository) Create(d *models.Dokter) (*models.Dokter, error) {
	tx, err := r.DB.Begin()
	if err != nil {
		return nil, err
	}

	queryDokter := `
		INSERT INTO tbdaftardokter ("NamaDokter", "NoTelp", "Spesialisasi", "Kategori", "Status", "Gambar", "TandaTangan", "IdBPJS")
		VALUES ($1, $2, 0, 0, 'aktif', '', '', '')
		RETURNING "IdDokter"
	`
	var realDokterID int
	err = tx.QueryRow(queryDokter, d.DoctorName, d.Phone).Scan(&realDokterID)
	if err != nil {
		tx.Rollback()
		return nil, err
	}

	var polyName string
	err = tx.QueryRow(`SELECT "NamaPoli" FROM tbpoli WHERE "IdPoli" = $1`, d.PolyID).Scan(&polyName)
	if err != nil {
		tx.Rollback()
		return nil, err
	}
	d.PolyName = polyName

	queryCategory := `
		INSERT INTO category (name, namadokter, "IdDokter", "IdPoli", app, options, voice_call, "MaxKuotaNonJKN", senin, selasa, rabu, kamis, jumat, sabtu, minggu)
		VALUES ($1, $2, $3, $4, 1, $5, '', $6, $7, $8, $9, $10, $11, $12, $13)
		RETURNING id
	`
	err = tx.QueryRow(queryCategory, polyName, d.DoctorName, realDokterID, d.PolyID, d.Schedule,
		d.MaxKuotaNonJKN, d.Senin, d.Selasa, d.Rabu, d.Kamis, d.Jumat, d.Sabtu, d.Minggu).Scan(&d.DoctorID)
	if err != nil {
		tx.Rollback()
		return nil, err
	}

	err = tx.Commit()
	if err != nil {
		return nil, err
	}
	d.Status = true
	return d, nil
}

func (r *DokterRepository) Update(d *models.Dokter) (*models.Dokter, error) {
	tx, err := r.DB.Begin()
	if err != nil {
		return nil, err
	}

	queryCategory := `
		UPDATE category
		SET namadokter = $1, "IdPoli" = $2, options = $3, "MaxKuotaNonJKN" = $4,
		    senin = $5, selasa = $6, rabu = $7, kamis = $8, jumat = $9, sabtu = $10, minggu = $11
		WHERE id = $12
		RETURNING "IdDokter"
	`
	var realDokterID int
	err = tx.QueryRow(queryCategory, d.DoctorName, d.PolyID, d.Schedule,
		d.MaxKuotaNonJKN, d.Senin, d.Selasa, d.Rabu, d.Kamis, d.Jumat, d.Sabtu, d.Minggu, d.DoctorID).Scan(&realDokterID)
	if err != nil {
		tx.Rollback()
		return nil, err
	}

	if realDokterID > 0 {
		queryDokter := `UPDATE tbdaftardokter SET "NamaDokter" = $1, "NoTelp" = $2 WHERE "IdDokter" = $3`
		_, err = tx.Exec(queryDokter, d.DoctorName, d.Phone, realDokterID)
		if err != nil {
			tx.Rollback()
			return nil, err
		}
	}

	err = tx.Commit()
	if err != nil {
		return nil, err
	}
	return d, nil
}

func (r *DokterRepository) Delete(id int) error {
	query := `DELETE FROM category WHERE id = $1`
	_, err := r.DB.Exec(query, id)
	return err
}