package repo

import (
	"context"
	"database/sql"
	"fmt"

	"giliran_ku_backend/models"
)

type CreateConsultationParams struct {
	TicketID   string
	PoliID     string
	DoctorID   string
	PatientNik string
}

type rowScanner interface {
	Scan(dest ...any) error
}

func (r *Repository) CreateConsultationTicket(
	ctx context.Context,
	params CreateConsultationParams,
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
		FROM tiket_antrian
		WHERE poli_id = $1
		AND created_at::date = CURRENT_DATE
	`, params.PoliID).Scan(&maxQueue)
	if err != nil {
		return models.Ticket{}, err
	}

	queueNumber := maxQueue + 1

	var maxAdmission int
	err = transaction.QueryRowContext(ctx, `
		SELECT COALESCE(MAX(admission_number), 0)
		FROM tiket_antrian
		WHERE created_at::date = CURRENT_DATE
	`).Scan(&maxAdmission)
	if err != nil {
		return models.Ticket{}, err
	}

	admissionNumber := maxAdmission + 1
	_, err = transaction.ExecContext(ctx, `
		INSERT INTO tiket_antrian (
			ticket_id,
			poli_id,
			doctor_id,
			patient_nik,
			queue_number,
			admission_number,
			created_at
		)
		VALUES ($1, $2, $3, $4, $5, $6, NOW())
	`, params.TicketID, params.PoliID, params.DoctorID, params.PatientNik, queueNumber, admissionNumber)
	if err != nil {
		return models.Ticket{}, err
	}

	if err := transaction.Commit(); err != nil {
		return models.Ticket{}, err
	}

	return r.GetTicketByID(ctx, params.TicketID)
}

func (r *Repository) GetTicketByID(ctx context.Context, ticketID string) (models.Ticket, error) {
	row := r.DB.QueryRowContext(ctx, `
		SELECT
			t.ticket_id,
			t.queue_number,
			t.admission_number,
			t.created_at,
			p.poli_id,
			p.poli_name,
			p.queue_prefix,
			d.doctor_id,
			d.doctor_name,
			pa.nik,
			pa.patient_name,
			kb.code_id
		FROM tiket_antrian t
		LEFT JOIN poliklinik p ON p.poli_id = t.poli_id
		LEFT JOIN dokter d ON d.doctor_id = t.doctor_id
		LEFT JOIN pasien pa ON pa.nik = t.patient_nik
		LEFT JOIN kode_booking kb ON kb.ticket_id = t.ticket_id
		WHERE t.ticket_id = $1
	`, ticketID)

	return scanTicket(row)
}

func (r *Repository) GetTicketByBookingCode(ctx context.Context, code string) (models.Ticket, error) {
	row := r.DB.QueryRowContext(ctx, `
		SELECT
			t.ticket_id,
			t.queue_number,
			t.admission_number,
			t.created_at,
			p.poli_id,
			p.poli_name,
			p.queue_prefix,
			d.doctor_id,
			d.doctor_name,
			pa.nik,
			pa.patient_name,
			kb.code_id
		FROM kode_booking kb
		JOIN tiket_antrian t ON t.ticket_id = kb.ticket_id
		LEFT JOIN poliklinik p ON p.poli_id = t.poli_id
		LEFT JOIN dokter d ON d.doctor_id = t.doctor_id
		LEFT JOIN pasien pa ON pa.nik = t.patient_nik
		WHERE kb.code_id = $1
	`, code)

	return scanTicket(row)
}

func scanTicket(scanner rowScanner) (models.Ticket, error) {
	var ticket models.Ticket
	var admissionNumber sql.NullInt64
	var poliID sql.NullString
	var poliName sql.NullString
	var queuePrefix sql.NullString
	var doctorID sql.NullString
	var doctorName sql.NullString
	var patientNik sql.NullString
	var patientName sql.NullString
	var bookingCode sql.NullString

	if err := scanner.Scan(
		&ticket.ID,
		&ticket.QueueNumber,
		&admissionNumber,
		&ticket.CreatedAt,
		&poliID,
		&poliName,
		&queuePrefix,
		&doctorID,
		&doctorName,
		&patientNik,
		&patientName,
		&bookingCode,
	); err != nil {
		return models.Ticket{}, err
	}

	if admissionNumber.Valid {
		ticket.AdmissionNumber = int(admissionNumber.Int64)
	}

	if poliID.Valid {
		ticket.Poli = &models.Poli{
			ID:   poliID.String,
			Name: poliName.String,
		}
	}
	if queuePrefix.Valid && ticket.QueueNumber > 0 {
		ticket.PoliQueueCode = fmt.Sprintf("%s%03d", queuePrefix.String, ticket.QueueNumber)
	}
	if doctorID.Valid {
		ticket.Doctor = &models.Doctor{
			ID:   doctorID.String,
			Name: doctorName.String,
		}
	}
	if patientNik.Valid {
		ticket.Patient = &models.Patient{
			Nik:  patientNik.String,
			Name: patientName.String,
		}
	}
	if bookingCode.Valid {
		ticket.BookingCode = &bookingCode.String
	}

	return ticket, nil
}
