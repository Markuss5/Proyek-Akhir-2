ALTER TABLE tiket_antrian
ALTER COLUMN ticket_id TYPE VARCHAR(50);

ALTER TABLE tiket_apotek
ALTER COLUMN apotek_ticket_id TYPE VARCHAR(50);

ALTER TABLE kode_booking
ALTER COLUMN ticket_id TYPE VARCHAR(50);
