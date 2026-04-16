-- PostgreSQL version of tbpoli
DROP TABLE IF EXISTS tbpoli CASCADE;
CREATE TABLE tbpoli (
  "IdPoli" SERIAL PRIMARY KEY,
  "NamaPoli" VARCHAR(55) DEFAULT '-',
  "KodePoli" VARCHAR(55) DEFAULT NULL,
  "TipePoli" INTEGER NOT NULL,
  "Spesialis" TEXT NOT NULL DEFAULT '[]',
  "KodeSatuSehat" VARCHAR(255) DEFAULT NULL
);
CREATE INDEX idx_tbpoli_tipepoli ON tbpoli ("TipePoli");

INSERT INTO tbpoli ("IdPoli", "NamaPoli", "KodePoli", "TipePoli", "Spesialis", "KodeSatuSehat") VALUES
(1, 'POLI DALAM', 'INT', 0, '["4"]', 'c212bc2b-a154-49c7-b09a-888eb3a0b525'),
(2, 'POLI THT', 'THT', 0, '["14"]', '47c64b4f-054d-4c68-bf9e-c4940a3ae033'),
(3, 'POLI GIGI', 'GIG', 1, '["33"]', 'd7658d17-2a1a-42cc-843d-87768dd315bc'),
(4, 'POLI ANAK', 'ANA', 0, '["5"]', 'f0b0fbf7-0e3e-44da-8f81-b24bbee503e2'),
(5, 'POLI SYARAF', 'SAR', 0, '["18"]', '40460da9-7042-4903-b750-883a5fc51faf'),
(7, 'POLI JIWA', 'JIW', 0, '["12"]', 'e289eaa6-8c64-4bfa-acc8-fe5dc9ab8b95'),
(9, 'POLI PARU', 'PAR', 0, '["17"]', 'f1f70d57-514a-4ba6-8ba1-f799dac635d2'),
(11, 'RADIOLOGI', 'RAD', 3, '["7"]', '5e26a829-68e0-45d0-9e12-f3b2287775a3'),
(12, 'POLI UMUM', 'POLIUMUM', 1, '["1"]', '1dea3d52-93b9-4e5a-bde2-5ca3ec807f73'),
(13, 'POLI KANDUNGAN', 'OBG', 0, '["6"]', '9f2500fb-5413-4eb1-9082-744afe6e6f0b'),
(14, 'POLI BEDAH', 'BED', 0, '["3"]', '0b191b08-a1fe-494c-80c1-13a381d4bd07'),
(15, 'POLI JANTUNG', 'JAN', 0, '["16"]', '8e798024-bd27-4685-98aa-75387d447385'),
(21, 'POLI OK', 'OK', 0, '["3","6","10","13"]', 'ab0d17cb-cc1b-4365-bca4-03c00a7d8d14'),
(24, 'POLI MATA', 'MAT', 0, '["13"]', '75908cad-db19-423d-a31f-93d00feefef2'),
(28, 'LABORATORIUM', 'LAB', 3, '["11"]', 'cbb5ff71-06fa-478e-a658-c339575fb378'),
(34, 'POLI VK', 'VK', 0, '["6"]', '2cf42092-8d37-49e0-ad06-270c5524e2f9'),
(36, 'POLI KULIT KELAMIN', 'KUL', 0, '["15"]', 'd78e0b27-cde6-4e4a-85b7-19f9c85fc4ed'),
(38, 'IGD PONEK', 'IGD', 0, '["1","6"]', '830ce517-6946-43e8-b071-909faee7c2cc'),
(40, 'POLI FORENSIK', '0', 0, '["23"]', '85d37263-3509-4d25-b09a-fa0139e03537'),
(44, 'LABORATORIUM', 'LABB', 0, '["11"]', NULL),
(45, 'GASTROENTEROLOGI-HEPATOLOGI', '005', 0, '["32"]', '48558afb-72d0-4486-b0ac-2cba2b09651c'),
(46, 'BEDAH ONKOLOGI', '017', 0, '["32"]', 'a7f000e4-00af-4d32-8874-21230acb1925'),
(47, 'HEMATOLOGI - ONKOLOGI MEDIK', '008', 0, '[]', '6d8cf26d-232f-4d5f-9ae2-95db8a8731d1'),
(48, 'ORTHOPEDI', 'ORT', 0, '["31"]', 'd00f1c19-b239-4191-b942-c7b861b1ff2b'),
(49, 'UROLOGI', 'URO', 0, '["21"]', 'e0d9d99e-ef67-45ce-91d7-b9aa0b936b05'),
(50, 'LAB PA', 'labpa', 3, '["22"]', 'd2d7f585-b471-4f57-99a0-bb272966e1b8'),
(52, 'GIGI ORTHODONTI', 'GOR', 0, '["166"]', 'b9b1a753-e34e-4ad9-9a51-5a5fb547de7c'),
(53, 'MIKROBIOLOGI KLINIK', 'MKB', 3, '["27"]', 'a68f5fff-855f-4ab8-813d-5762c0309114'),
(55, 'FISIOTERAPI', 'FST', 3, '["80","81"]', NULL),
(56, 'GIGI ENDODONSI', 'GND', 0, '["34"]', NULL),
(57, 'KARDIOVASKULAR', '015', 0, '["4","32"]', NULL);

-- Reset the sequence to max IdPoli
SELECT setval(pg_get_serial_sequence('tbpoli', 'IdPoli'), COALESCE(MAX("IdPoli"), 1)) FROM tbpoli;