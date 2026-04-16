-- PostgreSQL version of tbspesialis
DROP TABLE IF EXISTS tbspesialis CASCADE;
CREATE TABLE tbspesialis (
  id SERIAL PRIMARY KEY,
  kelompok INTEGER NOT NULL,
  jenis INTEGER NOT NULL,
  nama VARCHAR(255) NOT NULL,
  nama_alias VARCHAR(255) NOT NULL DEFAULT '',
  jumlah_tenaga INTEGER DEFAULT NULL
);

INSERT INTO tbspesialis (id, kelompok, jenis, nama, nama_alias, jumlah_tenaga) VALUES
(1, 1, 1, 'Dokter Umum', 'dokter_umum', NULL),
(2, 1, 1, 'Dokter PPDS', 'dokter_ppds', NULL),
(3, 1, 1, 'Dokter Spes Bedah', 'dokter_spes_bedah', NULL),
(4, 1, 1, 'Dokter Spes Penyakit Dalam', 'dokter_spes_penyakit_dalam', NULL),
(5, 1, 1, 'Dokter Spes Kes Anak', 'dokter_spes_kes_anak', NULL),
(6, 1, 1, 'Dokter Spes Obgin', 'dokter_spes_obgin', NULL),
(7, 1, 1, 'Dokter Spes Radiologi', 'dokter_spes_radiologi', NULL),
(8, 1, 1, 'Dokter Spes Onkologi Radiasi', 'dokter_spes_onkologi_radiasi', NULL),
(9, 1, 1, 'Dokter Spes Kedokteran Nuklir', 'dokter_spes_kedokteran_nuklir', NULL),
(10, 1, 1, 'Dokter Spes Anesthesi', 'dokter_spes_anesthesi', NULL),
(11, 1, 1, 'Dokter Spes Patologi Klinik', 'dokter_spes_patologi_klinik', NULL),
(12, 1, 1, 'Dokter Spes Jiwa', 'dokter_spes_jiwa', NULL),
(13, 1, 1, 'Dokter Spes Mata', 'dokter_spes_mata', NULL),
(14, 1, 1, 'Dokter Spes THT', 'dokter_spes_tht', NULL),
(15, 1, 1, 'Dokter Spes Kulit Kelamin', 'dokter_spes_kulit_kelamin', NULL),
(16, 1, 1, 'Dokter Spes Kardiologi', 'dokter_spes_kardiologi', NULL),
(17, 1, 1, 'Dokter Spes Paru', 'dokter_spes_paru', NULL),
(18, 1, 1, 'Dokter Spes Saraf', 'dokter_spes_saraf', NULL),
(19, 1, 1, 'Dokter Spes Bedah Saraf', 'dokter_spes_bedah_saraf', NULL),
(20, 1, 1, 'Dokter Spes Bedah Orthopedi', 'dokter_spes_bedah_orthopedi', NULL),
(21, 1, 1, 'Dokter Spes Urologi', 'dokter_spes_urologi', NULL),
(22, 1, 1, 'Dokter Spes Patologi Anatomi', 'dokter_spes_patologi_anatomi', NULL),
(23, 1, 1, 'Dokter Spes Patologi Forensik', 'dokter_spes_patologi_forensik', NULL),
(24, 1, 1, 'Dokter Spes Rehabilitasi Medik', 'dokter_spes_rehabilitasi_medik', NULL),
(25, 1, 1, 'Dokter Spes Bedah Plastik', 'dokter_spes_bedah_plastik', NULL),
(26, 1, 1, 'Dokter Spes Ked Olah Raga', 'dokter_spes_ked_olah_raga', NULL),
(27, 1, 1, 'Dokter Spes Mikrobiologi Klinik', 'dokter_spes_mikrobiologi_klinik', NULL),
(28, 1, 1, 'Dokter Spes Parasitologi Klinik', 'dokter_spes_parasitologi_klinik', NULL),
(29, 1, 1, 'Dokter Spes Gizi Medik', 'dokter_spes_gizi_medik', NULL),
(30, 1, 1, 'Dokter Spes Farma Klinik', 'dokter_spes_farma_klinik', NULL),
(31, 1, 1, 'Dokter Spes Lainnya', 'dokter_spes_lainnya', NULL),
(32, 1, 1, 'Dokter Sub Spesialis Lainnya', 'dokter_sub_spesialis_lainnya', NULL),
(33, 1, 1, 'Dokter Gigi', 'dokter_gigi', NULL),
(34, 1, 1, 'Dokter Gigi Spesialis', 'dokter_gigi_spesialis', NULL),
(166, 1, 2, 'Dokter Spesialis ortodonti', 'dokter_spesialis_ortodonti', NULL);

SELECT setval(pg_get_serial_sequence('tbspesialis', 'id'), COALESCE(MAX(id), 1)) FROM tbspesialis;