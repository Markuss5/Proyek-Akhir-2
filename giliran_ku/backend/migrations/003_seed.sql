INSERT INTO poliklinik (poli_id, poli_name, description, is_active)
VALUES
	('POLI-UMUM', 'Poli Umum', 'Pelayanan umum', true),
	('POLI-GIGI', 'Poli Gigi', 'Pelayanan gigi', true),
	('POLI-ANAK', 'Poli Anak', 'Pelayanan anak', true)
ON CONFLICT (poli_id) DO NOTHING;

INSERT INTO dokter (doctor_id, poli_id, doctor_name, specialization, phone, status)
VALUES
	('DR-001', 'POLI-UMUM', 'dr. Sari', 'Umum', '08123456789', 'aktif'),
	('DR-002', 'POLI-UMUM', 'dr. Rafi', 'Umum', '08123456788', 'aktif'),
	('DRG-001', 'POLI-GIGI', 'drg. Maya', 'Gigi', '08123456787', 'aktif'),
	('DR-101', 'POLI-ANAK', 'dr. Nisa', 'Anak', '08123456786', 'aktif')
ON CONFLICT (doctor_id) DO NOTHING;

INSERT INTO pasien (nik, patient_name, phone, email, bpjs_number)
VALUES
	('3201002003004001', 'Ayu Wulandari', '081300000001', 'ayu@example.com', '0001112223334'),
	('3201002003004002', 'Bagas Pratama', '081300000002', 'bagas@example.com', '0001112223335')
ON CONFLICT (nik) DO NOTHING;

INSERT INTO tiket_antrian (ticket_id, poli_id, doctor_id, patient_nik, queue_number, created_at)
VALUES
	('TKT-BOOK-001', 'POLI-GIGI', 'DRG-001', '3201002003004001', 12, NOW())
ON CONFLICT (ticket_id) DO NOTHING;

INSERT INTO kode_booking (code_id, ticket_id, created_at)
VALUES
	('BK001', 'TKT-BOOK-001', NOW())
ON CONFLICT (code_id) DO NOTHING;
