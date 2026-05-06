package repo

import (
	"context"
	"time"

	"giliran_ku_backend/models"
)

func (r *Repository) CreatePharmacyTicket(
	ctx context.Context,
	ticketID string,
	patientNik *string,
) (models.Ticket, error) {
	transaction, err := r.DB.BeginTx(ctx, nil)
	if err != nil {
		return models.Ticket{}, err
	}
	defer func() {
		if err != nil {
			_ = transaction.Rollback()
		}
	}()

	var maxQueue int
	err = transaction.QueryRowContext(ctx, `
		SELECT COALESCE(MAX(queue_number), 0)
		FROM tiket_apotek
		WHERE created_at::date = CURRENT_DATE
	`).Scan(&maxQueue)
	if err != nil {
		return models.Ticket{}, err
	}

	queueNumber := maxQueue + 1
	var createdAt time.Time
	err = transaction.QueryRowContext(ctx, `
		INSERT INTO tiket_apotek (apotek_ticket_id, queue_number, patient_nik, created_at)
		VALUES ($1, $2, $3, NOW())
		RETURNING created_at
	`, ticketID, queueNumber, patientNik).Scan(&createdAt)
	if err != nil {
		return models.Ticket{}, err
	}

	if err := transaction.Commit(); err != nil {
		return models.Ticket{}, err
	}

	ticket := models.Ticket{
		ID:          ticketID,
		QueueNumber: queueNumber,
		Type:        "farmasi",
		CreatedAt:   createdAt,
	}
	if patientNik != nil {
		ticket.Patient = &models.Patient{Nik: *patientNik}
	}

	return ticket, nil
}
