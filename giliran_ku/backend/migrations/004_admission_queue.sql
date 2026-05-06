ALTER TABLE poliklinik
ADD COLUMN IF NOT EXISTS queue_prefix VARCHAR(10) DEFAULT 'M';

UPDATE poliklinik
SET queue_prefix = 'M'
WHERE queue_prefix IS NULL;

ALTER TABLE tiket_antrian
ADD COLUMN IF NOT EXISTS admission_number INTEGER;

CREATE INDEX IF NOT EXISTS idx_tiket_antrian_admission_date
ON tiket_antrian (created_at);
