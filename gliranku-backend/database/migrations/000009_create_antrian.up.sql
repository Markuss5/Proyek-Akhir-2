-- Rumah Sakit profile information (single-row config table)
CREATE TABLE IF NOT EXISTS tbrumahsakit (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL DEFAULT '',
  description TEXT NOT NULL DEFAULT '',
  vision TEXT NOT NULL DEFAULT '',
  mission JSON NOT NULL DEFAULT '[]',
  op_hours JSON NOT NULL DEFAULT '{}',
  facilities JSON NOT NULL DEFAULT '[]',
  address TEXT NOT NULL DEFAULT '',
  phone VARCHAR(50) NOT NULL DEFAULT '',
  email VARCHAR(255) NOT NULL DEFAULT ''
);

INSERT INTO tbrumahsakit (id, name, description, vision, mission, op_hours, facilities, address, phone, email)
VALUES (1,
  'RSUD Porsea',
  'RSUD Porsea adalah pusat layanan kesehatan masyarakat yang berdedikasi memberikan pelayanan medis berkualitas tinggi di wilayah Toba. Kami mengutamakan kenyamanan dan keselamatan pasien melalui tenaga medis profesional.',
  'Menjadi Rumah Sakit Pilihan Utama dengan Pelayanan Prima di Wilayah Toba.',
  '["SDM Profesional: Meningkatkan kompetensi dan integritas tenaga kesehatan.", "Sarana & Prasarana: Meningkatkan kualitas fasilitas pendukung pelayanan.", "Manajemen Efisien: Menerapkan sistem manajemen yang transparan, efektif, dan akuntabel.", "Kualitas Layanan: Menyelenggarakan perbaikan berkelanjutan terhadap mutu layanan untuk kepuasan pasien."]',
  '{"Senin - Sabtu": "08:00 - 16:00 WIB", "Minggu": "Libur (Kecuali IGD)", "IGD": "Buka 24 Jam"}',
  '["Poliklinik Umum", "Rawat Inap", "IGD 24 Jam", "Laboratorium", "Radiologi", "Farmasi"]',
  'Jl. Patuan Nagari, Porsea, Kab. Toba, Sumatera Utara',
  '(0632) 41012',
  'info@rsudporsea.go.id'
) ON CONFLICT (id) DO NOTHING;
