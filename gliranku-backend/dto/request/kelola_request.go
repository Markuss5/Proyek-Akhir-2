package request

type InformasiRequest struct {
	Name        string            `json:"name" binding:"required"`
	Description string            `json:"description" binding:"required"`
	Vision      string            `json:"vision" binding:"required"`
	Mission     []string          `json:"mission" binding:"required"`
	OpHours     map[string]string `json:"op_hours" binding:"required"`
	Facilities  []string          `json:"facilities" binding:"required"`
	Address     string            `json:"address" binding:"required"`
	Phone       string            `json:"phone" binding:"required"`
	Email       string            `json:"email" binding:"required"`
}

type PoliRequest struct {
	PolyName    string `json:"poly_name" binding:"required"`
	KodePoli    string `json:"kode_poli" binding:"required"`
	Description string `json:"description"`
}

type DokterRequest struct {
	DoctorName     string `json:"doctor_name" binding:"required"`
	Specialization string `json:"specialization" binding:"required"`
	PolyID         int    `json:"poly_id" binding:"required"`
	Phone          string `json:"phone"`
	Schedule       string `json:"schedule"` // e.g., "Senin, Selasa"
}
