ALTER TABLE Kontrol_Rutin ALTER COLUMN controlDate TYPE DATE USING controlDate::DATE;
ALTER TABLE Notifikasi ALTER COLUMN scheduledDate TYPE DATE USING scheduledDate::DATE;
