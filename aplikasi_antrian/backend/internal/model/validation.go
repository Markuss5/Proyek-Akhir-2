package model

import "time"

type Patient struct {
	ID          string
	NIK         string
	BPJSNumber  string
	Name        string
	QueueNumber string
}

type QueueRecord struct {
	QueueCode    string
	QueueNumber  string
	PatientName  string
	ClinicName   string
	DoctorName   string
	ScheduleInfo string
	CreatedAt    time.Time
}

type NIKValidationRequest struct {
	NIK string `json:"nik"`
}

type BPJSOrNIKValidationRequest struct {
	Input string `json:"input"`
}

type QueueCodeValidationRequest struct {
	QueueCode string `json:"queueCode"`
}

type NIKValidationResponse struct {
	IsValid     bool   `json:"isValid"`
	Message     string `json:"message"`
	PatientID   string `json:"patientId,omitempty"`
	QueueNumber string `json:"queueNumber,omitempty"`
	PatientName string `json:"patientName,omitempty"`
}

type BPJSValidationResponse struct {
	IsValid     bool   `json:"isValid"`
	Message     string `json:"message"`
	QueueNumber string `json:"queueNumber,omitempty"`
	PatientName string `json:"patientName,omitempty"`
}

type QueueVerificationData struct {
	QueueCode    string    `json:"queueCode"`
	QueueNumber  string    `json:"queueNumber"`
	PatientName  string    `json:"patientName"`
	ClinicName   string    `json:"clinicName"`
	DoctorName   string    `json:"doctorName"`
	ScheduleInfo string    `json:"scheduleInfo"`
	CreatedAt    time.Time `json:"createdAt"`
}

type QueueCodeValidationResponse struct {
	IsValid bool                   `json:"isValid"`
	Message string                 `json:"message"`
	Data    *QueueVerificationData `json:"data,omitempty"`
}

type PharmacyQueue struct {
	ID                 string
	PharmacyQueueCode  string
	QueueNumber        string
	PatientID          string
	ClinicName         string
	DoctorName         string
	ScheduleInfo       string
	CreatedAt          time.Time
}

type PharmacyQueueResponse struct {
	IsValid     bool   `json:"isValid"`
	Message     string `json:"message"`
	QueueNumber string `json:"queueNumber,omitempty"`
	PatientName string `json:"patientName,omitempty"`
	ClinicName  string `json:"clinicName,omitempty"`
}
