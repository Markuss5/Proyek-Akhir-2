package repository

import (
	"database/sql"
	"gliranku/models"
	"time"
)

type NotifikasiRepository struct {
	DB *sql.DB
}

func NewNotifikasiRepository(db *sql.DB) *NotifikasiRepository {
	return &NotifikasiRepository{DB: db}
}

func (r *NotifikasiRepository) Create(notifikasi *models.Notifikasi) (*models.Notifikasi, error) {
	query := `
		INSERT INTO "Notifikasi" (message, "scheduledDate", "isSent", "NIK")
		VALUES ($1, $2, $3, $4)
		RETURNING "notificationID", message, "scheduledDate", "isSent", "sentAt", "NIK"
	`

	var result models.Notifikasi
	err := r.DB.QueryRow(
		query,
		notifikasi.Message,
		notifikasi.ScheduledDate,
		false,
		notifikasi.NIK,
	).Scan(
		&result.NotificationID,
		&result.Message,
		&result.ScheduledDate,
		&result.IsSent,
		&result.SentAt,
		&result.NIK,
	)
	if err != nil {
		return nil, err
	}
	return &result, nil
}

func (r *NotifikasiRepository) FindByNIK(nik string) ([]models.Notifikasi, error) {
	query := `
		SELECT "notificationID", message, "scheduledDate", "isSent", "sentAt", "NIK"
		FROM "Notifikasi"
		WHERE "NIK" = $1
		ORDER BY "scheduledDate" ASC
	`

	rows, err := r.DB.Query(query, nik)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []models.Notifikasi
	for rows.Next() {
		var n models.Notifikasi
		err := rows.Scan(&n.NotificationID, &n.Message, &n.ScheduledDate, &n.IsSent, &n.SentAt, &n.NIK)
		if err != nil {
			return nil, err
		}
		results = append(results, n)
	}
	return results, nil
}

func (r *NotifikasiRepository) FindPending() ([]models.Notifikasi, error) {
	query := `
		SELECT "notificationID", message, "scheduledDate", "isSent", "sentAt", "NIK"
		FROM "Notifikasi"
		WHERE "isSent" = false AND "scheduledDate" <= CURRENT_DATE
		ORDER BY "scheduledDate" ASC
	`

	rows, err := r.DB.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []models.Notifikasi
	for rows.Next() {
		var n models.Notifikasi
		err := rows.Scan(&n.NotificationID, &n.Message, &n.ScheduledDate, &n.IsSent, &n.SentAt, &n.NIK)
		if err != nil {
			return nil, err
		}
		results = append(results, n)
	}
	return results, nil
}

func (r *NotifikasiRepository) MarkAsSent(id int) error {
	query := `
		UPDATE "Notifikasi"
		SET "isSent" = true, "sentAt" = $1
		WHERE "notificationID" = $2
	`

	_, err := r.DB.Exec(query, time.Now(), id)
	return err
}
