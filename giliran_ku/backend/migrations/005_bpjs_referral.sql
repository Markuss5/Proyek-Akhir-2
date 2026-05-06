CREATE TABLE IF NOT EXISTS bpjs_referral (
  patient_nik VARCHAR(32) PRIMARY KEY REFERENCES pasien(nik)
    ON UPDATE CASCADE ON DELETE CASCADE,
  poli_id VARCHAR(30) NOT NULL REFERENCES poliklinik(poli_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  doctor_id VARCHAR(30) NOT NULL REFERENCES dokter(doctor_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  created_at TIMESTAMP NOT NULL DEFAULT now()
);

WITH default_poli AS (
  SELECT poli_id
  FROM poliklinik
  WHERE is_active = true
  ORDER BY poli_name
  LIMIT 1
),
first_doctor AS (
  SELECT d.doctor_id
  FROM dokter d
  JOIN default_poli p ON d.poli_id = p.poli_id
  ORDER BY d.doctor_name
  LIMIT 1
)
INSERT INTO bpjs_referral (patient_nik, poli_id, doctor_id)
SELECT p.nik, dp.poli_id, fd.doctor_id
FROM pasien p
CROSS JOIN default_poli dp
CROSS JOIN first_doctor fd
WHERE NOT EXISTS (
  SELECT 1 FROM bpjs_referral r WHERE r.patient_nik = p.nik
);
