-- ================================================================
--  DUMMY DATA — GlaucoScan Database
--  Jalankan query ini di database PostgreSQL/MySQL kamu
--  Urutan: harus sesuai karena ada foreign key
-- ================================================================


-- ================================================================
-- 0. TAMBAH KOLOM BARU (jalankan ini dulu sebelum insert data)
-- ================================================================

-- Tambah kolom ke tabel users
ALTER TABLE users ADD COLUMN IF NOT EXISTS nik VARCHAR(16) UNIQUE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS username VARCHAR(50) UNIQUE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS date_of_birth DATE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS gender VARCHAR(10) CHECK (gender IN ('male', 'female'));
ALTER TABLE users ADD COLUMN IF NOT EXISTS address TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS city VARCHAR(80);
ALTER TABLE users ADD COLUMN IF NOT EXISTS province VARCHAR(80);
ALTER TABLE users ADD COLUMN IF NOT EXISTS religion VARCHAR(50);
ALTER TABLE users ADD COLUMN IF NOT EXISTS nationality VARCHAR(50) DEFAULT 'Indonesia';

-- Tambah kolom ke tabel doctors
ALTER TABLE doctors ADD COLUMN IF NOT EXISTS doctor_id_number VARCHAR(20) UNIQUE;
ALTER TABLE doctors ADD COLUMN IF NOT EXISTS str_number VARCHAR(50) UNIQUE;
ALTER TABLE doctors ADD COLUMN IF NOT EXISTS str_expired_at DATE;
ALTER TABLE doctors ADD COLUMN IF NOT EXISTS sip_number VARCHAR(50) UNIQUE;
ALTER TABLE doctors ADD COLUMN IF NOT EXISTS sip_expired_at DATE;
ALTER TABLE doctors ADD COLUMN IF NOT EXISTS education VARCHAR(100);
ALTER TABLE doctors ADD COLUMN IF NOT EXISTS alumni VARCHAR(100);
ALTER TABLE doctors ADD COLUMN IF NOT EXISTS graduation_year INT;
ALTER TABLE doctors ADD COLUMN IF NOT EXISTS office_phone VARCHAR(20);
ALTER TABLE doctors ADD COLUMN IF NOT EXISTS office_email VARCHAR(150);

-- Tambah kolom ke tabel patients
ALTER TABLE patients ADD COLUMN IF NOT EXISTS medical_record_number VARCHAR(20) UNIQUE;
ALTER TABLE patients ADD COLUMN IF NOT EXISTS bpjs_number VARCHAR(20) UNIQUE;
ALTER TABLE patients ADD COLUMN IF NOT EXISTS marital_status VARCHAR(20) CHECK (marital_status IN ('single','married','divorced','widowed'));
ALTER TABLE patients ADD COLUMN IF NOT EXISTS occupation VARCHAR(100);
ALTER TABLE patients ADD COLUMN IF NOT EXISTS patient_status VARCHAR(20) DEFAULT 'active';
ALTER TABLE patients ADD COLUMN IF NOT EXISTS registration_date DATE;


-- ================================================================
-- 1. SPECIALIZATIONS
-- ================================================================

INSERT INTO specializations (id, name, description, is_active, created_at, updated_at) VALUES
(1, 'Glaukoma',           'Spesialisasi penanganan dan deteksi penyakit glaukoma pada mata', true, NOW(), NOW()),
(2, 'Retina',             'Spesialisasi penyakit dan kelainan pada retina mata',             true, NOW(), NOW()),
(3, 'Kornea',             'Spesialisasi penyakit dan transplantasi kornea mata',             true, NOW(), NOW()),
(4, 'Katarak',            'Spesialisasi operasi dan penanganan katarak',                     true, NOW(), NOW()),
(5, 'Neuro-Oftalmologi',  'Spesialisasi gangguan mata yang berhubungan dengan saraf',       true, NOW(), NOW()),
(6, 'Pediatrik Oftalmologi', 'Spesialisasi kesehatan mata pada anak-anak',                  true, NOW(), NOW());


-- ================================================================
-- 2. USERS
-- ================================================================

-- ── ADMIN
INSERT INTO users (id, name, email, password, phone, role, is_active, nik, username, date_of_birth, gender, address, city, province, religion, nationality, email_verified_at, created_at, updated_at) VALUES
(1, 'Super Admin',    'admin@glaucoscan.com',    '$2y$12$hashed_password_here', '081200000001', 'admin',   true, '3201010101800001', 'superadmin',  '1980-01-01', 'male',   'Jl. Sudirman No. 1',       'Jakarta',   'DKI Jakarta',    'Islam',  'Indonesia', NOW(), NOW(), NOW()),
(2, 'Admin Operasional', 'ops@glaucoscan.com',   '$2y$12$hashed_password_here', '081200000002', 'admin',   true, '3201010201800002', 'adminops',    '1985-02-01', 'female', 'Jl. Thamrin No. 5',        'Jakarta',   'DKI Jakarta',    'Kristen','Indonesia', NOW(), NOW(), NOW());

-- ── DOKTER
INSERT INTO users (id, name, email, password, phone, role, is_active, nik, username, date_of_birth, gender, address, city, province, religion, nationality, email_verified_at, created_at, updated_at) VALUES
(3,  'dr. Budi Santoso, SpM',       'budi.santoso@glaucoscan.com',    '$2y$12$hashed_password_here', '081311110001', 'doctor', true, '3201010101750003', 'dr_budi',      '1975-03-15', 'male',   'Jl. Gatot Subroto No. 10',  'Jakarta',   'DKI Jakarta',    'Islam',  'Indonesia', NOW(), NOW(), NOW()),
(4,  'dr. Sari Dewi, SpM',          'sari.dewi@glaucoscan.com',       '$2y$12$hashed_password_here', '081311110002', 'doctor', true, '3201010101800004', 'dr_sari',      '1980-07-20', 'female', 'Jl. Kuningan No. 22',       'Jakarta',   'DKI Jakarta',    'Kristen','Indonesia', NOW(), NOW(), NOW()),
(5,  'dr. Ahmad Fauzi, SpM',        'ahmad.fauzi@glaucoscan.com',     '$2y$12$hashed_password_here', '081311110003', 'doctor', true, '3201010101780005', 'dr_ahmad',     '1978-11-05', 'male',   'Jl. MT. Haryono No. 8',     'Jakarta',   'DKI Jakarta',    'Islam',  'Indonesia', NOW(), NOW(), NOW()),
(6,  'dr. Linda Kusuma, SpM',       'linda.kusuma@glaucoscan.com',    '$2y$12$hashed_password_here', '081311110004', 'doctor', true, '3201010101820006', 'dr_linda',     '1982-04-25', 'female', 'Jl. Casablanca No. 15',     'Jakarta',   'DKI Jakarta',    'Katolik','Indonesia', NOW(), NOW(), NOW()),
(7,  'dr. Hendra Wijaya, SpM',      'hendra.wijaya@glaucoscan.com',   '$2y$12$hashed_password_here', '081311110005', 'doctor', true, '3201010101770007', 'dr_hendra',    '1977-09-12', 'male',   'Jl. Rasuna Said No. 3',     'Jakarta',   'DKI Jakarta',    'Islam',  'Indonesia', NOW(), NOW(), NOW()),
(8,  'dr. Ratna Sari, SpM',         'ratna.sari@glaucoscan.com',      '$2y$12$hashed_password_here', '081311110006', 'doctor', true, '3201010101850008', 'dr_ratna',     '1985-12-30', 'female', 'Jl. Semanggi No. 7',        'Jakarta',   'DKI Jakarta',    'Budha', 'Indonesia', NOW(), NOW(), NOW());

-- ── PASIEN
INSERT INTO users (id, name, email, password, phone, role, is_active, nik, username, date_of_birth, gender, address, city, province, religion, nationality, email_verified_at, created_at, updated_at) VALUES
(9,  'Andi Wijaya',      'andi.wijaya@gmail.com',      '$2y$12$hashed_password_here', '082111110001', 'patient', true, '3275010109900001', 'andi_w',    '1990-05-10', 'male',   'Jl. Kebon Jeruk No. 12',    'Jakarta',   'DKI Jakarta',    'Islam',  'Indonesia', NOW(), NOW(), NOW()),
(10, 'Bela Puspita',     'bela.puspita@gmail.com',     '$2y$12$hashed_password_here', '082111110002', 'patient', true, '3275010209950002', 'bela_p',    '1995-08-22', 'female', 'Jl. Kemanggisan No. 5',     'Jakarta',   'DKI Jakarta',    'Kristen','Indonesia', NOW(), NOW(), NOW()),
(11, 'Cahyo Nugroho',    'cahyo.nugroho@gmail.com',    '$2y$12$hashed_password_here', '082111110003', 'patient', true, '3275010309880003', 'cahyo_n',   '1988-02-14', 'male',   'Jl. Pondok Indah No. 8',    'Jakarta',   'DKI Jakarta',    'Islam',  'Indonesia', NOW(), NOW(), NOW()),
(12, 'Dewi Lestari',     'dewi.lestari@gmail.com',     '$2y$12$hashed_password_here', '082111110004', 'patient', true, '3275010409920004', 'dewi_l',    '1992-11-03', 'female', 'Jl. Menteng No. 20',        'Jakarta',   'DKI Jakarta',    'Islam',  'Indonesia', NOW(), NOW(), NOW()),
(13, 'Eko Prasetyo',     'eko.prasetyo@gmail.com',     '$2y$12$hashed_password_here', '082111110005', 'patient', true, '3275010509870005', 'eko_p',     '1987-06-18', 'male',   'Jl. Tebet No. 33',          'Jakarta',   'DKI Jakarta',    'Kristen','Indonesia', NOW(), NOW(), NOW()),
(14, 'Fitri Handayani',  'fitri.handayani@gmail.com',  '$2y$12$hashed_password_here', '082111110006', 'patient', true, '3275010609930006', 'fitri_h',   '1993-09-27', 'female', 'Jl. Mampang No. 11',        'Jakarta',   'DKI Jakarta',    'Islam',  'Indonesia', NOW(), NOW(), NOW()),
(15, 'Gilang Ramadhan',  'gilang.ramadhan@gmail.com',  '$2y$12$hashed_password_here', '082111110007', 'patient', true, '3275010709850007', 'gilang_r',  '1985-01-07', 'male',   'Jl. Cempaka Putih No. 4',   'Jakarta',   'DKI Jakarta',    'Islam',  'Indonesia', NOW(), NOW(), NOW()),
(16, 'Hani Pertiwi',     'hani.pertiwi@gmail.com',     '$2y$12$hashed_password_here', '082111110008', 'patient', true, '3275010809970008', 'hani_p',    '1997-04-15', 'female', 'Jl. Pasar Minggu No. 6',    'Jakarta',   'DKI Jakarta',    'Katolik','Indonesia', NOW(), NOW(), NOW()),
(17, 'Irfan Hakim',      'irfan.hakim@gmail.com',      '$2y$12$hashed_password_here', '082111110009', 'patient', true, '3275010909910009', 'irfan_h',   '1991-07-23', 'male',   'Jl. Cipete No. 9',          'Jakarta',   'DKI Jakarta',    'Islam',  'Indonesia', NOW(), NOW(), NOW()),
(18, 'Julia Rahma',      'julia.rahma@gmail.com',      '$2y$12$hashed_password_here', '082111110010', 'patient', true, '3275011009960010', 'julia_r',   '1996-12-01', 'female', 'Jl. Senayan No. 17',        'Jakarta',   'DKI Jakarta',    'Islam',  'Indonesia', NOW(), NOW(), NOW());


-- ================================================================
-- 3. ADMINS
-- ================================================================

INSERT INTO admins (id, user_id, admin_level, created_at, updated_at) VALUES
(1, 1, 'superadmin', NOW(), NOW()),
(2, 2, 'staff',      NOW(), NOW());


-- ================================================================
-- 4. DOCTORS
-- ================================================================

INSERT INTO doctors (id, user_id, specialization_id, doctor_id_number, license_number, str_number, str_expired_at, sip_number, sip_expired_at, education, alumni, graduation_year, practice_location, experience_years, consultation_fee, is_available, office_phone, office_email, bio, created_at, updated_at) VALUES
(1, 3, 1, 'DR-2024-0001', 'SIP-001/2024', 'STR-001/2024', '2027-12-31', 'SIP-001/2024', '2026-12-31', 'S1 Kedokteran + SpM',  'Universitas Indonesia',       2003, 'Poli Mata Lt. 2 Ruang 201', 20, 250000, true,  '02112345001', 'budi.prof@rs.com',   'Dokter spesialis mata dengan fokus pada deteksi dan penanganan glaukoma sejak 2003.',   NOW(), NOW()),
(2, 4, 2, 'DR-2024-0002', 'SIP-002/2024', 'STR-002/2024', '2027-12-31', 'SIP-002/2024', '2026-12-31', 'S1 Kedokteran + SpM',  'Universitas Gadjah Mada',     2005, 'Poli Mata Lt. 2 Ruang 202', 18, 275000, true,  '02112345002', 'sari.prof@rs.com',   'Spesialis retina berpengalaman dengan keahlian dalam degenerasi makula dan ablasio retina.', NOW(), NOW()),
(3, 5, 1, 'DR-2024-0003', 'SIP-003/2024', 'STR-003/2024', '2027-12-31', 'SIP-003/2024', '2026-12-31', 'S1 Kedokteran + SpM',  'Universitas Airlangga',       2000, 'Poli Mata Lt. 2 Ruang 203', 23, 300000, true,  '02112345003', 'ahmad.prof@rs.com',  'Senior dokter spesialis glaukoma dengan pengalaman lebih dari 23 tahun.',               NOW(), NOW()),
(4, 6, 3, 'DR-2024-0004', 'SIP-004/2024', 'STR-004/2024', '2027-12-31', 'SIP-004/2024', '2026-12-31', 'S1 Kedokteran + SpM',  'Universitas Padjadjaran',     2007, 'Poli Mata Lt. 2 Ruang 204', 16, 225000, true,  '02112345004', 'linda.prof@rs.com',  'Spesialis kornea dan bedah refraktif.',                                                  NOW(), NOW()),
(5, 7, 4, 'DR-2024-0005', 'SIP-005/2024', 'STR-005/2024', '2027-12-31', 'SIP-005/2024', '2026-12-31', 'S1 Kedokteran + SpM',  'Universitas Diponegoro',      2002, 'Poli Mata Lt. 2 Ruang 205', 21, 250000, true,  '02112345005', 'hendra.prof@rs.com', 'Ahli bedah katarak dan pemasangan lensa intraokular.',                                   NOW(), NOW()),
(6, 8, 2, 'DR-2024-0006', 'SIP-006/2024', 'STR-006/2024', '2027-12-31', 'SIP-006/2024', '2026-12-31', 'S1 Kedokteran + SpM',  'Universitas Hasanuddin',      2010, 'Poli Mata Lt. 2 Ruang 206', 13, 200000, true,  '02112345006', 'ratna.prof@rs.com',  'Spesialis retina muda dengan keahlian laser fotokoagulasi.',                             NOW(), NOW());


-- ================================================================
-- 5. PATIENTS
-- ================================================================

INSERT INTO patients (id, user_id, medical_record_number, bpjs_number, date_of_birth, gender, address, city, province, postal_code, blood_type, marital_status, occupation, emergency_contact_name, emergency_contact_phone, emergency_contact_relation, medical_history, allergies, insurance_provider, insurance_number, patient_status, registration_date, created_at, updated_at) VALUES
(1,  9,  'RM-2024-000001', '0001234560001', '1990-05-10', 'male',   'Jl. Kebon Jeruk No. 12',   'Jakarta', 'DKI Jakarta', '11530', 'O+', 'married',  'Karyawan Swasta',  'Siti Wijaya',    '082100000001', 'Istri',  'Hipertensi ringan sejak 2018',            'Penisilin',   'BPJS Kesehatan', '0001234560001', 'active', '2024-01-10', NOW(), NOW()),
(2,  10, 'RM-2024-000002', '0001234560002', '1995-08-22', 'female', 'Jl. Kemanggisan No. 5',    'Jakarta', 'DKI Jakarta', '11480', 'A+', 'single',   'Mahasiswa',        'Budi Puspita',   '082100000002', 'Ayah',   'Tidak ada riwayat penyakit serius',       'Tidak ada',   'BPJS Kesehatan', '0001234560002', 'active', '2024-01-15', NOW(), NOW()),
(3,  11, 'RM-2024-000003', '0001234560003', '1988-02-14', 'male',   'Jl. Pondok Indah No. 8',   'Jakarta', 'DKI Jakarta', '12310', 'B+', 'married',  'Wiraswasta',       'Ani Nugroho',    '082100000003', 'Istri',  'Diabetes tipe 2 sejak 2015',              'Sulfa',       'Prudential',     'PRU-2024-001',  'active', '2024-01-20', NOW(), NOW()),
(4,  12, 'RM-2024-000004', '0001234560004', '1992-11-03', 'female', 'Jl. Menteng No. 20',       'Jakarta', 'DKI Jakarta', '10310', 'AB+','married',  'PNS',              'Joko Lestari',   '082100000004', 'Suami',  'Miopia tinggi -8.00',                     'Tidak ada',   'BPJS Kesehatan', '0001234560004', 'active', '2024-02-01', NOW(), NOW()),
(5,  13, 'RM-2024-000005', '0001234560005', '1987-06-18', 'male',   'Jl. Tebet No. 33',         'Jakarta', 'DKI Jakarta', '12810', 'O-', 'divorced', 'Pengusaha',        'Rina Prasetyo',  '082100000005', 'Kakak',  'Glaukoma mata kiri terdiagnosis 2020',    'Aspirin',     'Allianz',        'ALZ-2024-001',  'active', '2024-02-10', NOW(), NOW()),
(6,  14, 'RM-2024-000006', '0001234560006', '1993-09-27', 'female', 'Jl. Mampang No. 11',       'Jakarta', 'DKI Jakarta', '12790', 'A-', 'single',   'Guru',             'Ahmad Handayani','082100000006', 'Ayah',   'Tidak ada riwayat penyakit mata',         'Tidak ada',   'BPJS Kesehatan', '0001234560006', 'active', '2024-02-15', NOW(), NOW()),
(7,  15, 'RM-2024-000007', '0001234560007', '1985-01-07', 'male',   'Jl. Cempaka Putih No. 4',  'Jakarta', 'DKI Jakarta', '10510', 'B-', 'married',  'TNI',              'Susi Ramadhan',  '082100000007', 'Istri',  'Tekanan darah tinggi, riwayat katarak',   'Tidak ada',   'Askes TNI',      'TNI-2024-001',  'active', '2024-03-01', NOW(), NOW()),
(8,  16, 'RM-2024-000008', '0001234560008', '1997-04-15', 'female', 'Jl. Pasar Minggu No. 6',   'Jakarta', 'DKI Jakarta', '12520', 'O+', 'single',   'Mahasiswa',        'Deni Pertiwi',   '082100000008', 'Ayah',   'Tidak ada',                               'Tidak ada',   'BPJS Kesehatan', '0001234560008', 'active', '2024-03-10', NOW(), NOW()),
(9,  17, 'RM-2024-000009', '0001234560009', '1991-07-23', 'male',   'Jl. Cipete No. 9',         'Jakarta', 'DKI Jakarta', '12410', 'A+', 'married',  'Dokter Umum',      'Maya Hakim',     '082100000009', 'Istri',  'Astigmatisme berat',                      'Tidak ada',   'IDI',            'IDI-2024-001',  'active', '2024-03-15', NOW(), NOW()),
(10, 18, 'RM-2024-000010', '0001234560010', '1996-12-01', 'female', 'Jl. Senayan No. 17',       'Jakarta', 'DKI Jakarta', '10270', 'B+', 'single',   'Karyawan Swasta',  'Hadi Rahma',     '082100000010', 'Ayah',   'Mata lelah kronis akibat layar komputer', 'Tidak ada',   'BPJS Kesehatan', '0001234560010', 'active', '2024-03-20', NOW(), NOW());


-- ================================================================
-- 6. DOCTOR SCHEDULES
-- ================================================================

INSERT INTO doctor_schedules (id, doctor_id, day_of_week, start_time, end_time, is_available, max_patients, created_at, updated_at) VALUES
-- Dokter Budi Santoso (Glaukoma)
(1,  1, 'monday',    '08:00:00', '12:00:00', true, 10, NOW(), NOW()),
(2,  1, 'wednesday', '08:00:00', '12:00:00', true, 10, NOW(), NOW()),
(3,  1, 'friday',    '13:00:00', '17:00:00', true, 8,  NOW(), NOW()),
-- Dokter Sari Dewi (Retina)
(4,  2, 'tuesday',   '08:00:00', '12:00:00', true, 10, NOW(), NOW()),
(5,  2, 'thursday',  '08:00:00', '12:00:00', true, 10, NOW(), NOW()),
(6,  2, 'saturday',  '08:00:00', '11:00:00', true, 6,  NOW(), NOW()),
-- Dokter Ahmad Fauzi (Glaukoma)
(7,  3, 'monday',    '13:00:00', '17:00:00', true, 8,  NOW(), NOW()),
(8,  3, 'wednesday', '13:00:00', '17:00:00', true, 8,  NOW(), NOW()),
(9,  3, 'friday',    '08:00:00', '12:00:00', true, 10, NOW(), NOW()),
-- Dokter Linda Kusuma (Kornea)
(10, 4, 'tuesday',   '13:00:00', '17:00:00', true, 8,  NOW(), NOW()),
(11, 4, 'thursday',  '13:00:00', '17:00:00', true, 8,  NOW(), NOW()),
-- Dokter Hendra Wijaya (Katarak)
(12, 5, 'monday',    '08:00:00', '12:00:00', true, 10, NOW(), NOW()),
(13, 5, 'tuesday',   '08:00:00', '12:00:00', true, 10, NOW(), NOW()),
(14, 5, 'thursday',  '08:00:00', '12:00:00', true, 10, NOW(), NOW()),
-- Dokter Ratna Sari (Retina)
(15, 6, 'wednesday', '08:00:00', '12:00:00', true, 10, NOW(), NOW()),
(16, 6, 'friday',    '08:00:00', '12:00:00', true, 10, NOW(), NOW()),
(17, 6, 'saturday',  '08:00:00', '11:00:00', true, 6,  NOW(), NOW());


-- ================================================================
-- 7. APPOINTMENTS
-- ================================================================

INSERT INTO appointments (id, patient_id, doctor_id, appointment_date, appointment_time, appointment_status, patient_complaint, doctor_notes, rejection_reason, confirmed_by, confirmed_at, created_at, updated_at) VALUES
(1,  1,  1, '2024-03-01', '08:00:00', 'completed',            'Mata kiri sering terasa berat dan kabur saat pagi hari',                       'Pasien terindikasi glaukoma sudut terbuka', NULL,                        3, '2024-02-25 10:00:00', '2024-02-24 09:00:00', NOW()),
(2,  2,  2, '2024-03-02', '09:00:00', 'completed',            'Penglihatan tiba-tiba menurun di mata kanan sejak seminggu lalu',               'Perlu pemeriksaan retina lanjutan',         NULL,                        4, '2024-02-26 11:00:00', '2024-02-25 08:00:00', NOW()),
(3,  3,  1, '2024-03-05', '10:00:00', 'completed',            'Melihat lingkaran cahaya di sekitar lampu pada malam hari',                     'Glaukoma sudut terbuka stadium awal',       NULL,                        3, '2024-03-01 09:00:00', '2024-02-28 10:00:00', NOW()),
(4,  4,  3, '2024-03-06', '13:00:00', 'completed',            'Mata terasa nyeri dan tekanan tinggi',                                          'Tekanan intraokular 28 mmHg',               NULL,                        5, '2024-03-02 10:00:00', '2024-03-01 09:00:00', NOW()),
(5,  5,  1, '2024-03-08', '08:00:00', 'completed',            'Kontrol rutin glaukoma mata kiri',                                              'Kondisi stabil setelah pengobatan',         NULL,                        3, '2024-03-04 09:00:00', '2024-03-03 10:00:00', NOW()),
(6,  6,  2, '2024-03-10', '09:00:00', 'completed',            'Floaters dan kilatan cahaya di mata kanan',                                     'Ablasio retina parsial, perlu laser',       NULL,                        4, '2024-03-06 10:00:00', '2024-03-05 08:00:00', NOW()),
(7,  7,  5, '2024-03-12', '08:00:00', 'completed',            'Penglihatan buram seperti melihat melalui kabut',                               'Katarak stadium 2 mata kiri',               NULL,                        7, '2024-03-08 09:00:00', '2024-03-07 10:00:00', NOW()),
(8,  8,  4, '2024-03-15', '13:00:00', 'confirmed',            'Mata perih dan merah setelah memakai softlens',                                 NULL,                                         NULL,                        6, '2024-03-11 10:00:00', '2024-03-10 09:00:00', NOW()),
(9,  9,  3, '2024-03-18', '14:00:00', 'pending_confirmation', 'Tekanan mata tinggi dan sakit kepala terus-menerus',                            NULL,                                         NULL,                        NULL, NULL,                '2024-03-12 11:00:00', NOW()),
(10, 10, 6, '2024-03-20', '09:00:00', 'pending_confirmation', 'Mata lelah, buram saat menatap layar terlalu lama',                             NULL,                                         NULL,                        NULL, NULL,                '2024-03-13 10:00:00', NOW()),
(11, 1,  1, '2024-03-22', '10:00:00', 'pending_payment',      'Kontrol lanjutan glaukoma',                                                     NULL,                                         NULL,                        NULL, NULL,                '2024-03-14 09:00:00', NOW()),
(12, 3,  3, '2024-03-25', '13:00:00', 'rejected',             'Mata merah dan berair sudah 3 hari',                                            NULL,                                         'Jadwal penuh, silakan reschedule', 5, '2024-03-10 09:00:00', '2024-03-09 10:00:00', NOW()),
(13, 4,  1, '2024-04-01', '08:00:00', 'confirmed',            'Keluhan tekanan mata tinggi kambuh',                                            NULL,                                         NULL,                        3, '2024-03-20 10:00:00', '2024-03-19 09:00:00', NOW()),
(14, 2,  4, '2024-04-02', '13:00:00', 'confirmed',            'Mata terasa kering dan perih',                                                  NULL,                                         NULL,                        6, '2024-03-21 11:00:00', '2024-03-20 10:00:00', NOW());


-- ================================================================
-- 8. PAYMENTS
-- ================================================================

INSERT INTO payments (id, appointment_id, invoice_number, amount, payment_status, payment_method, transaction_id, paid_at, expired_at, created_at, updated_at) VALUES
(1,  1,  'INV-20240301-001', 250000, 'paid',   'bpjs',            'TRX-001-2024', '2024-02-24 09:30:00', '2024-03-01 09:00:00', NOW(), NOW()),
(2,  2,  'INV-20240302-002', 275000, 'paid',   'bank_transfer',   'TRX-002-2024', '2024-02-25 08:30:00', '2024-03-02 09:00:00', NOW(), NOW()),
(3,  3,  'INV-20240305-003', 250000, 'paid',   'dummy',           'TRX-003-2024', '2024-02-28 10:30:00', '2024-03-05 09:00:00', NOW(), NOW()),
(4,  4,  'INV-20240306-004', 300000, 'paid',   'virtual_account', 'TRX-004-2024', '2024-03-01 09:30:00', '2024-03-06 09:00:00', NOW(), NOW()),
(5,  5,  'INV-20240308-005', 250000, 'paid',   'bpjs',            'TRX-005-2024', '2024-03-03 10:30:00', '2024-03-08 09:00:00', NOW(), NOW()),
(6,  6,  'INV-20240310-006', 275000, 'paid',   'bank_transfer',   'TRX-006-2024', '2024-03-05 08:30:00', '2024-03-10 09:00:00', NOW(), NOW()),
(7,  7,  'INV-20240312-007', 250000, 'paid',   'dummy',           'TRX-007-2024', '2024-03-07 10:30:00', '2024-03-12 09:00:00', NOW(), NOW()),
(8,  8,  'INV-20240315-008', 225000, 'paid',   'virtual_account', 'TRX-008-2024', '2024-03-10 09:30:00', '2024-03-15 09:00:00', NOW(), NOW()),
(9,  9,  'INV-20240318-009', 300000, 'paid',   'bank_transfer',   'TRX-009-2024', '2024-03-12 11:30:00', '2024-03-18 09:00:00', NOW(), NOW()),
(10, 10, 'INV-20240320-010', 200000, 'paid',   'dummy',           'TRX-010-2024', '2024-03-13 10:30:00', '2024-03-20 09:00:00', NOW(), NOW()),
(11, 11, 'INV-20240322-011', 250000, 'unpaid',  'dummy',          NULL,            NULL,                  '2024-03-21 09:00:00', NOW(), NOW()),
(12, 12, 'INV-20240325-012', 300000, 'refunded','dummy',          'TRX-012-2024', '2024-03-09 10:30:00', '2024-03-25 09:00:00', NOW(), NOW()),
(13, 13, 'INV-20240401-013', 250000, 'paid',   'bpjs',            'TRX-013-2024', '2024-03-19 09:30:00', '2024-04-01 09:00:00', NOW(), NOW()),
(14, 14, 'INV-20240402-014', 225000, 'paid',   'bank_transfer',   'TRX-014-2024', '2024-03-20 10:30:00', '2024-04-02 09:00:00', NOW(), NOW());


-- ================================================================
-- 9. EXAMINATIONS
-- ================================================================

INSERT INTO examinations (id, appointment_id, patient_id, doctor_id, examination_code, examination_date, examination_time, status, clinical_notes, doctor_diagnosis, recommendation, created_at, updated_at) VALUES
(1, 1, 1, 1, 'EXM-20240301-001', '2024-03-01', '08:30:00', 'completed', 'Tekanan intraokular mata kiri 26 mmHg, mata kanan 18 mmHg. Cup-to-disc ratio 0.7', 'Glaukoma sudut terbuka primer mata kiri stadium awal', 'Mulai tetes mata timolol 0.5% 2x sehari. Kontrol 1 bulan lagi.', NOW(), NOW()),
(2, 2, 2, 2, 'EXM-20240302-002', '2024-03-02', '09:30:00', 'completed', 'Retina mata kanan tampak edema di area makula. Pembuluh darah melebar.', 'Degenerasi makula basah mata kanan stadium awal', 'Injeksi anti-VEGF intravitreal. Jadwal 1 bulan sekali selama 3 bulan.', NOW(), NOW()),
(3, 3, 3, 1, 'EXM-20240305-003', '2024-03-05', '10:30:00', 'completed', 'Lapang pandang menyempit di perifer. TIO 24 mmHg bilateral.', 'Glaukoma sudut terbuka primer bilateral stadium sedang', 'Tambah obat dorzolamide. Pertimbangkan operasi trabekulektomi jika tidak membaik.', NOW(), NOW()),
(4, 4, 4, 3, 'EXM-20240306-004', '2024-03-06', '13:30:00', 'completed', 'TIO 28 mmHg mata kanan. Sudut drainase tertutup sebagian.', 'Glaukoma sudut tertutup akut mata kanan', 'Segera laser iridotomi. Mulai asetazolamid oral.', NOW(), NOW()),
(5, 5, 5, 1, 'EXM-20240308-005', '2024-03-08', '08:30:00', 'completed', 'TIO mata kiri turun ke 16 mmHg setelah pengobatan. Kondisi membaik.', 'Glaukoma sudut terbuka mata kiri terkontrol', 'Lanjutkan tetes mata timolol. Kontrol 3 bulan lagi.', NOW(), NOW()),
(6, 6, 6, 2, 'EXM-20240310-006', '2024-03-10', '09:30:00', 'completed', 'Retina ablasio parsial di kuadran superior temporal mata kanan.', 'Ablasio retina regmatogen mata kanan', 'Segera laser retinopeksi. Hindari aktivitas berat.', NOW(), NOW()),
(7, 7, 7, 5, 'EXM-20240312-007', '2024-03-12', '08:30:00', 'completed', 'Lensa mata kiri keruh grade 2+. Visus 6/18.', 'Katarak imatur mata kiri', 'Rencanakan operasi fakoemulsifikasi + IOL. Tunggu katarak matang stadium 3.', NOW(), NOW()),
(8, 8, 8, 4, 'EXM-20240315-008', '2024-03-15', '13:30:00', 'processing', 'Kornea tampak edema ringan. Ada infiltrat perifer.', NULL, NULL, NOW(), NOW());


-- ================================================================
-- 10. ML MODEL VERSIONS
-- ================================================================

INSERT INTO ml_model_versions (id, version_name, architecture, dataset_used, accuracy, sensitivity, specificity, auc_roc, f1_score, precision, total_training_data, total_validation_data, is_active, description, deployed_at, deployed_by, created_at, updated_at) VALUES
(1, 'v1.0.0', 'VGG19',          'ORIGA + RIM-ONE',         0.8923, 0.8745, 0.9102, 0.9312, 0.8834, 0.8967, 3000, 750, false, 'Model awal menggunakan VGG19. Akurasi cukup baik tapi lambat.',     '2024-01-01 00:00:00', 1, NOW(), NOW()),
(2, 'v1.5.0', 'ResNet50',       'ORIGA + RIM-ONE + DRISHTI',0.9145, 0.9023, 0.9267, 0.9534, 0.9084, 0.9201, 4500, 1125, false, 'Upgrade ke ResNet50. Akurasi meningkat signifikan.',                '2024-03-01 00:00:00', 1, NOW(), NOW()),
(3, 'v2.0.0', 'EfficientNetB0', 'ORIGA + REFUGE + DRISHTI', 0.9312, 0.9178, 0.9445, 0.9712, 0.9256, 0.9334, 6000, 1500, false, 'Migrasi ke EfficientNet. Lebih ringan dan akurasi lebih baik.',     '2024-06-01 00:00:00', 1, NOW(), NOW()),
(4, 'v2.1.0', 'EfficientNetB4', 'ORIGA + REFUGE + DRISHTI + G1020', 0.9523, 0.9401, 0.9645, 0.9812, 0.9462, 0.9534, 8000, 2000, true, 'Model terbaik saat ini. EfficientNetB4 dengan dataset lebih besar.', '2024-09-01 00:00:00', 1, NOW(), NOW());


-- ================================================================
-- 11. FUNDUS IMAGES
-- ================================================================

INSERT INTO fundus_images (id, examination_id, uploaded_by, original_filename, stored_filename, file_path, file_url, file_format, file_size_bytes, image_width_px, image_height_px, eye_side, device_name, capture_notes, is_valid, uploaded_at, created_at, updated_at) VALUES
(1, 1, 3, 'fundus_andi_left.jpg',   'fi_001_20240301.jpg', 'storage/fundus/fi_001_20240301.jpg', '/storage/fundus/fi_001_20240301.jpg', 'jpg', 2048576, 2056, 2056, 'left',  'Topcon TRC-50DX', 'Pupil cukup lebar, kualitas baik',          true, '2024-03-01 08:15:00', NOW(), NOW()),
(2, 1, 3, 'fundus_andi_right.jpg',  'fi_002_20240301.jpg', 'storage/fundus/fi_002_20240301.jpg', '/storage/fundus/fi_002_20240301.jpg', 'jpg', 1987654, 2056, 2056, 'right', 'Topcon TRC-50DX', 'Kualitas baik',                             true, '2024-03-01 08:20:00', NOW(), NOW()),
(3, 2, 4, 'fundus_bela_right.jpg',  'fi_003_20240302.jpg', 'storage/fundus/fi_003_20240302.jpg', '/storage/fundus/fi_003_20240302.jpg', 'jpg', 2156789, 2056, 2056, 'right', 'Zeiss FF 450+',   'Ada artefak sedikit, masih bisa dianalisis', true, '2024-03-02 09:15:00', NOW(), NOW()),
(4, 3, 3, 'fundus_cahyo_both.jpg',  'fi_004_20240305.jpg', 'storage/fundus/fi_004_20240305.jpg', '/storage/fundus/fi_004_20240305.jpg', 'jpg', 3045678, 2056, 2056, 'both',  'Topcon TRC-50DX', 'Kedua mata difoto sekaligus',               true, '2024-03-05 10:15:00', NOW(), NOW()),
(5, 4, 5, 'fundus_dewi_right.jpg',  'fi_005_20240306.jpg', 'storage/fundus/fi_005_20240306.jpg', '/storage/fundus/fi_005_20240306.jpg', 'jpg', 2087654, 2056, 2056, 'right', 'Canon CR-2 AF',   'Kualitas sangat baik',                      true, '2024-03-06 13:15:00', NOW(), NOW()),
(6, 5, 3, 'fundus_eko_left.jpg',    'fi_006_20240308.jpg', 'storage/fundus/fi_006_20240308.jpg', '/storage/fundus/fi_006_20240308.jpg', 'jpg', 1956789, 2056, 2056, 'left',  'Topcon TRC-50DX', 'Kontrol rutin, kualitas baik',              true, '2024-03-08 08:15:00', NOW(), NOW()),
(7, 6, 4, 'fundus_fitri_right.jpg', 'fi_007_20240310.jpg', 'storage/fundus/fi_007_20240310.jpg', '/storage/fundus/fi_007_20240310.jpg', 'jpg', 2234567, 2056, 2056, 'right', 'Zeiss FF 450+',   'Kualitas baik, retina terlihat jelas',      true, '2024-03-10 09:15:00', NOW(), NOW()),
(8, 7, 7, 'fundus_gilang_left.jpg', 'fi_008_20240312.jpg', 'storage/fundus/fi_008_20240312.jpg', '/storage/fundus/fi_008_20240312.jpg', 'jpg', 2098765, 2056, 2056, 'left',  'Canon CR-2 AF',   'Lensa sedikit keruh, kualitas cukup',       true, '2024-03-12 08:15:00', NOW(), NOW()),
(9, 8, 6, 'fundus_hani_both.jpg',   'fi_009_20240315.jpg', 'storage/fundus/fi_009_20240315.jpg', '/storage/fundus/fi_009_20240315.jpg', 'jpg', 3156789, 2056, 2056, 'both',  'Topcon TRC-50DX', 'Kedua mata, kualitas baik',                 true, '2024-03-15 13:15:00', NOW(), NOW());


-- ================================================================
-- 12. ANALYSIS RESULTS
-- ================================================================

INSERT INTO analysis_results (id, examination_id, fundus_image_id, model_version_id, prediction, confidence_score, glaucoma_probability, normal_probability, heatmap_image_path, status, processing_time_ms, analyzed_at, created_at, updated_at) VALUES
(1, 1, 1, 4, 'glaucoma', 0.9234, 0.9234, 0.0766, 'storage/heatmap/hm_001_20240301.jpg', 'completed', 1245, '2024-03-01 08:18:00', NOW(), NOW()),
(2, 1, 2, 4, 'normal',   0.8912, 0.1088, 0.8912, 'storage/heatmap/hm_002_20240301.jpg', 'completed', 1189, '2024-03-01 08:23:00', NOW(), NOW()),
(3, 2, 3, 4, 'glaucoma', 0.7823, 0.7823, 0.2177, 'storage/heatmap/hm_003_20240302.jpg', 'completed', 1356, '2024-03-02 09:18:00', NOW(), NOW()),
(4, 3, 4, 4, 'glaucoma', 0.9567, 0.9567, 0.0433, 'storage/heatmap/hm_004_20240305.jpg', 'completed', 1423, '2024-03-05 10:18:00', NOW(), NOW()),
(5, 4, 5, 4, 'glaucoma', 0.9812, 0.9812, 0.0188, 'storage/heatmap/hm_005_20240306.jpg', 'completed', 1298, '2024-03-06 13:18:00', NOW(), NOW()),
(6, 5, 6, 4, 'normal',   0.9123, 0.0877, 0.9123, 'storage/heatmap/hm_006_20240308.jpg', 'completed', 1167, '2024-03-08 08:18:00', NOW(), NOW()),
(7, 6, 7, 4, 'normal',   0.8456, 0.1544, 0.8456, 'storage/heatmap/hm_007_20240310.jpg', 'completed', 1289, '2024-03-10 09:18:00', NOW(), NOW()),
(8, 7, 8, 4, 'normal',   0.7934, 0.2066, 0.7934, 'storage/heatmap/hm_008_20240312.jpg', 'completed', 1345, '2024-03-12 08:18:00', NOW(), NOW()),
(9, 8, 9, 4, NULL,        NULL,   NULL,   NULL,   NULL,                                   'processing', NULL, NULL,                NOW(), NOW());


-- ================================================================
-- 13. NOTIFICATIONS
-- ================================================================

INSERT INTO notifications (id, user_id, title, message, type, channel, is_read, sent_at, created_at, updated_at) VALUES
('notif-001', 9,  'Janji Temu Dikonfirmasi',     'Janji temu Anda dengan dr. Budi Santoso pada 01 Maret 2024 telah dikonfirmasi.',          'appointment_confirmed',  'push', true,  '2024-02-25 10:00:00', NOW(), NOW()),
('notif-002', 9,  'Pembayaran Berhasil',          'Pembayaran invoice INV-20240301-001 sebesar Rp 250.000 telah berhasil dikonfirmasi.',      'payment_confirmed',      'push', true,  '2024-02-24 09:30:00', NOW(), NOW()),
('notif-003', 9,  'Hasil Pemeriksaan Tersedia',   'Hasil pemeriksaan mata Anda pada 01 Maret 2024 sudah tersedia. Silakan cek aplikasi.',    'analysis_ready',         'push', true,  '2024-03-01 09:00:00', NOW(), NOW()),
('notif-004', 10, 'Janji Temu Dikonfirmasi',      'Janji temu Anda dengan dr. Sari Dewi pada 02 Maret 2024 telah dikonfirmasi.',             'appointment_confirmed',  'push', true,  '2024-02-26 11:00:00', NOW(), NOW()),
('notif-005', 10, 'Hasil Pemeriksaan Tersedia',   'Hasil pemeriksaan mata Anda pada 02 Maret 2024 sudah tersedia.',                          'analysis_ready',         'push', false, '2024-03-02 10:00:00', NOW(), NOW()),
('notif-006', 3,  'Janji Temu Baru',              'Pasien Andi Wijaya telah membuat janji temu untuk 01 Maret 2024 pukul 08:00.',            'appointment_created',    'push', true,  '2024-02-24 09:00:00', NOW(), NOW()),
('notif-007', 3,  'Hasil ML Selesai',             'Hasil analisis ML pemeriksaan EXM-20240301-001 sudah siap untuk ditinjau.',               'examination_completed',  'push', true,  '2024-03-01 08:20:00', NOW(), NOW()),
('notif-008', 4,  'Janji Temu Baru',              'Pasien Bela Puspita telah membuat janji temu untuk 02 Maret 2024 pukul 09:00.',           'appointment_created',    'push', true,  '2024-02-25 08:00:00', NOW(), NOW()),
('notif-009', 11, 'Janji Temu Ditolak',           'Maaf, janji temu Anda pada 25 Maret 2024 ditolak. Alasan: Jadwal penuh.',                 'appointment_rejected',   'push', true,  '2024-03-10 09:00:00', NOW(), NOW()),
('notif-010', 9,  'Pengingat Janji Temu',         'Mengingatkan Anda memiliki janji temu dengan dr. Budi Santoso besok pukul 10:00.',        'appointment_confirmed',  'push', false, '2024-03-21 08:00:00', NOW(), NOW());


-- ================================================================
-- 14. ACTIVITY LOGS
-- ================================================================

INSERT INTO activity_logs (id, user_id, action, module, description, subject_type, subject_id, ip_address, user_agent, created_at) VALUES
(1,  9,  'register',           'auth',        'Pasien Andi Wijaya melakukan registrasi akun baru',                    'User',        9,  '192.168.1.10', 'Mozilla/5.0 Flutter App', '2024-01-10 08:00:00'),
(2,  9,  'login',              'auth',        'Pasien Andi Wijaya login ke aplikasi mobile',                          'User',        9,  '192.168.1.10', 'Mozilla/5.0 Flutter App', '2024-02-24 08:55:00'),
(3,  9,  'create_appointment', 'appointment', 'Pasien Andi Wijaya membuat janji temu dengan dr. Budi Santoso',        'Appointment', 1,  '192.168.1.10', 'Mozilla/5.0 Flutter App', '2024-02-24 09:00:00'),
(4,  9,  'payment',            'payment',     'Pasien Andi Wijaya melakukan pembayaran INV-20240301-001',             'Payment',     1,  '192.168.1.10', 'Mozilla/5.0 Flutter App', '2024-02-24 09:30:00'),
(5,  3,  'login',              'auth',        'Dokter Budi Santoso login ke Web Dokter',                              'User',        3,  '192.168.1.20', 'Mozilla/5.0 Chrome/120',  '2024-02-25 09:55:00'),
(6,  3,  'confirm_appointment','appointment', 'Dokter Budi Santoso mengkonfirmasi janji temu pasien Andi Wijaya',     'Appointment', 1,  '192.168.1.20', 'Mozilla/5.0 Chrome/120',  '2024-02-25 10:00:00'),
(7,  3,  'upload_fundus',      'examination', 'Dokter Budi Santoso mengupload fundus image untuk pasien Andi Wijaya', 'FundusImage', 1,  '192.168.1.20', 'Mozilla/5.0 Chrome/120',  '2024-03-01 08:15:00'),
(8,  3,  'add_diagnosis',      'examination', 'Dokter Budi Santoso mengisi diagnosis untuk EXM-20240301-001',         'Examination', 1,  '192.168.1.20', 'Mozilla/5.0 Chrome/120',  '2024-03-01 08:45:00'),
(9,  1,  'login',              'auth',        'Admin login ke Web Admin',                                             'User',        1,  '192.168.1.30', 'Mozilla/5.0 Chrome/120',  '2024-03-01 07:55:00'),
(10, 1,  'create_doctor',      'admin',       'Admin membuat akun dokter baru: dr. Ratna Sari',                       'User',        8,  '192.168.1.30', 'Mozilla/5.0 Chrome/120',  '2024-02-01 09:00:00'),
(11, 1,  'activate_ml_model',  'ml',          'Admin mengaktifkan model ML versi v2.1.0',                             'MLModel',     4,  '192.168.1.30', 'Mozilla/5.0 Chrome/120',  '2024-09-01 08:00:00'),
(12, 5,  'reject_appointment', 'appointment', 'Dokter Ahmad Fauzi menolak janji temu pasien Cahyo Nugroho',           'Appointment', 12, '192.168.1.25', 'Mozilla/5.0 Chrome/120',  '2024-03-10 09:00:00'),
(13, 10, 'login',              'auth',        'Pasien Bela Puspita login ke aplikasi mobile',                         'User',        10, '192.168.1.11', 'Mozilla/5.0 Flutter App', '2024-02-25 07:55:00'),
(14, 10, 'create_appointment', 'appointment', 'Pasien Bela Puspita membuat janji temu dengan dr. Sari Dewi',          'Appointment', 2,  '192.168.1.11', 'Mozilla/5.0 Flutter App', '2024-02-25 08:00:00'),
(15, 1,  'toggle_user_status', 'admin',       'Admin menonaktifkan akun user ID 20 (spam account)',                   'User',        20, '192.168.1.30', 'Mozilla/5.0 Chrome/120',  '2024-03-05 10:00:00');


-- ================================================================
--  SELESAI — Semua dummy data sudah diinsert
--  Total data:
--  - Specializations  : 6
--  - Users            : 18 (2 admin, 6 dokter, 10 pasien)
--  - Admins           : 2
--  - Doctors          : 6
--  - Patients         : 10
--  - Doctor Schedules : 17
--  - Appointments     : 14
--  - Payments         : 14
--  - Examinations     : 8
--  - ML Model Versions: 4
--  - Fundus Images    : 9
--  - Analysis Results : 9
--  - Notifications    : 10
--  - Activity Logs    : 15
-- ================================================================