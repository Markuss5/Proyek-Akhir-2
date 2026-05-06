package models

type Patient struct {
	Nik        string `json:"nik"`
	Name       string `json:"name"`
	Phone      string `json:"phone,omitempty"`
	Email      string `json:"email,omitempty"`
	BpjsNumber string `json:"bpjs_number,omitempty"`
}
