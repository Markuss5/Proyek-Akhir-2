ALTER TABLE pasien
ADD COLUMN IF NOT EXISTS bpjs_number VARCHAR(32);

ALTER TABLE tiket_antrian
ADD COLUMN IF NOT EXISTS doctor_id VARCHAR(30);

DO $$
BEGIN
	IF NOT EXISTS (
		SELECT 1 FROM pg_constraint WHERE conname = 'fk_tiket_antrian_doctor'
	) THEN
		ALTER TABLE tiket_antrian
		ADD CONSTRAINT fk_tiket_antrian_doctor
		FOREIGN KEY (doctor_id) REFERENCES dokter(doctor_id)
		ON UPDATE CASCADE
		ON DELETE SET NULL;
	END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_tiket_antrian_poli_date
ON tiket_antrian (poli_id, created_at);

CREATE INDEX IF NOT EXISTS idx_tiket_apotek_date
ON tiket_apotek (created_at);
