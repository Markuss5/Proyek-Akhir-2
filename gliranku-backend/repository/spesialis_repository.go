package repository

import (
	"database/sql"
	"gliranku/models"
)

type SpesialisRepository struct {
	DB *sql.DB
}

func NewSpesialisRepository(db *sql.DB) *SpesialisRepository {
	return &SpesialisRepository{DB: db}
}

func (r *SpesialisRepository) FindAll() ([]models.Spesialis, error) {
	query := `
		SELECT id, kelompok, jenis, nama, nama_alias, jumlah_tenaga
		FROM tbspesialis
		ORDER BY id ASC
	`
	rows, err := r.DB.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []models.Spesialis
	for rows.Next() {
		var s models.Spesialis
		var jumlahTenaga sql.NullInt64
		err := rows.Scan(&s.ID, &s.Kelompok, &s.Jenis, &s.Nama, &s.NamaAlias, &jumlahTenaga)
		if err != nil {
			return nil, err
		}
		if jumlahTenaga.Valid {
			val := int(jumlahTenaga.Int64)
			s.JumlahTenaga = &val
		}
		results = append(results, s)
	}
	return results, nil
}

func (r *SpesialisRepository) FindByID(id int) (*models.Spesialis, error) {
	query := `
		SELECT id, kelompok, jenis, nama, nama_alias, jumlah_tenaga
		FROM tbspesialis
		WHERE id = $1
	`
	var s models.Spesialis
	var jumlahTenaga sql.NullInt64

	err := r.DB.QueryRow(query, id).Scan(&s.ID, &s.Kelompok, &s.Jenis, &s.Nama, &s.NamaAlias, &jumlahTenaga)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	if jumlahTenaga.Valid {
		val := int(jumlahTenaga.Int64)
		s.JumlahTenaga = &val
	}
	return &s, nil
}

func (r *SpesialisRepository) Create(s *models.Spesialis) (*models.Spesialis, error) {
	query := `
		INSERT INTO tbspesialis (kelompok, jenis, nama, nama_alias, jumlah_tenaga)
		VALUES ($1, $2, $3, $4, $5)
		RETURNING id
	`
	err := r.DB.QueryRow(query, s.Kelompok, s.Jenis, s.Nama, s.NamaAlias, s.JumlahTenaga).Scan(&s.ID)
	if err != nil {
		return nil, err
	}
	return s, nil
}

func (r *SpesialisRepository) Update(s *models.Spesialis) (*models.Spesialis, error) {
	query := `
		UPDATE tbspesialis
		SET kelompok = $1, jenis = $2, nama = $3, nama_alias = $4, jumlah_tenaga = $5
		WHERE id = $6
	`
	_, err := r.DB.Exec(query, s.Kelompok, s.Jenis, s.Nama, s.NamaAlias, s.JumlahTenaga, s.ID)
	if err != nil {
		return nil, err
	}
	return s, nil
}

func (r *SpesialisRepository) Delete(id int) error {
	query := `DELETE FROM tbspesialis WHERE id = $1`
	_, err := r.DB.Exec(query, id)
	return err
}