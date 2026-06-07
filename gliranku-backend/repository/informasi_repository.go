package repository

import (
	"database/sql"
	"encoding/json"
	"gliranku/models"
)

type InformasiRepository struct {
	DB *sql.DB
}

func NewInformasiRepository(db *sql.DB) *InformasiRepository {
	return &InformasiRepository{DB: db}
}

func (r *InformasiRepository) Get() (*models.Informasi, error) {
	query := `SELECT id, name, description, vision, mission, op_hours, facilities, address, phone, email FROM tbrumahsakit WHERE id = 1`

	var info models.Informasi
	var missionBytes, opHoursBytes, facilitiesBytes []byte

	err := r.DB.QueryRow(query).Scan(
		&info.ID, &info.Name, &info.Description, &info.Vision,
		&missionBytes, &opHoursBytes, &facilitiesBytes,
		&info.Address, &info.Phone, &info.Email,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}

	json.Unmarshal(missionBytes, &info.Mission)
	json.Unmarshal(opHoursBytes, &info.OpHours)
	json.Unmarshal(facilitiesBytes, &info.Facilities)

	return &info, nil
}

func (r *InformasiRepository) Update(info *models.Informasi) (*models.Informasi, error) {
	query := `
		UPDATE tbrumahsakit
		SET name = $1, description = $2, vision = $3, mission = $4, op_hours = $5, facilities = $6, address = $7, phone = $8, email = $9
		WHERE id = 1
	`

	missionBytes, _ := json.Marshal(info.Mission)
	opHoursBytes, _ := json.Marshal(info.OpHours)
	facilitiesBytes, _ := json.Marshal(info.Facilities)

	_, err := r.DB.Exec(query,
		info.Name, info.Description, info.Vision,
		missionBytes, opHoursBytes, facilitiesBytes,
		info.Address, info.Phone, info.Email,
	)
	if err != nil {
		return nil, err
	}
	return info, nil
}