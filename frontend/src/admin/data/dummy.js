// --- STYLING CONSTANTS ---
export const COLORS = {
  primary: '#1565C0',
  secondary: '#42A5F5',
  bg: '#F5F7FA',
  glaucoma: { text: '#C62828', bg: '#FFEBEE' },
  normal: { text: '#2E7D32', bg: '#E8F5E9' },
  warning: { text: '#E65100', bg: '#FFF3E0' },
  info: { text: '#0277BD', bg: '#E1F5FE' },
  neutral: { text: '#616161', bg: '#F5F5F5' },
};

export const MONTHLY_DATA = [
  { name: 'Jan', Glaukoma: 40, Normal: 60 },
  { name: 'Feb', Glaukoma: 30, Normal: 70 },
  { name: 'Mar', Glaukoma: 45, Normal: 55 },
  { name: 'Apr', Glaukoma: 50, Normal: 50 },
  { name: 'Mei', Glaukoma: 35, Normal: 65 },
  { name: 'Jun', Glaukoma: 25, Normal: 75 },
  { name: 'Jul', Glaukoma: 42, Normal: 58 },
  { name: 'Agu', Glaukoma: 38, Normal: 62 },
  { name: 'Sep', Glaukoma: 30, Normal: 70 },
  { name: 'Okt', Glaukoma: 44, Normal: 56 },
  { name: 'Nov', Glaukoma: 48, Normal: 52 },
  { name: 'Des', Glaukoma: 35, Normal: 65 },
];

export const PIE_DATA = [
  { name: 'Glaukoma', value: 32 },
  { name: 'Normal', value: 68 },
];

export const MODEL_COMPARISON = [
  { version: 'v1.0.0', accuracy: 88.5 },
  { version: 'v1.5.0', accuracy: 91.2 },
  { version: 'v2.0.0', accuracy: 94.1 },
  { version: 'v2.1.0', accuracy: 95.2 },
];

export const RECENT_EXAMS = [
  { id: 1, patient: 'Budi Santoso', doctor: 'dr. Andi Sp.M', date: '2023-10-24', result: 'GLAUKOMA', confidence: '98.2%', status: 'completed' },
  { id: 2, patient: 'Siti Aminah', doctor: 'dr. Rani Sp.M', date: '2023-10-24', result: 'NORMAL', confidence: '99.1%', status: 'completed' },
  { id: 3, patient: 'Agus Wijaya', doctor: 'dr. Andi Sp.M', date: '2023-10-23', result: 'GLAUKOMA', confidence: '87.5%', status: 'completed' },
  { id: 4, patient: 'Dewi Lestari', doctor: 'dr. Rani Sp.M', date: '2023-10-23', result: 'NORMAL', confidence: '95.4%', status: 'completed' },
  { id: 5, patient: 'Eko Prasetyo', doctor: 'dr. Rani Sp.M', date: '2023-10-22', result: 'NORMAL', confidence: '92.8%', status: 'completed' },
];

export const USERS_DATA = [
  { id: 1, name: 'Budi Santoso', email: 'budi.s@email.com', role: 'PASIEN', phone: '081234567890', status: 'Aktif', joined: '12 Jan 2023' },
  { id: 2, name: 'dr. Andi Permadi', email: 'andi.spm@rsmata.com', role: 'DOKTER', phone: '085522114433', status: 'Aktif', joined: '05 Feb 2023' },
  { id: 3, name: 'Siti Aminah', email: 'siti88@email.com', role: 'PASIEN', phone: '089900112233', status: 'Nonaktif', joined: '18 Mar 2023' },
  { id: 4, name: 'Admin Utama', email: 'admin@rsmata.com', role: 'ADMIN', phone: '081122334455', status: 'Aktif', joined: '01 Jan 2023' },
  { id: 5, name: 'dr. Rani Wijaya', email: 'rani.spm@rsmata.com', role: 'DOKTER', phone: '081277665544', status: 'Aktif', joined: '10 Mei 2023' },
  ...Array(5).fill(null).map((_, i) => ({
    id: i + 6,
    name: `User Dummy ${i + 6}`,
    email: `user${i + 6}@mail.com`,
    role: 'PASIEN',
    phone: '08xxxxxx',
    status: 'Aktif',
    joined: '20 Okt 2023',
  })),
];

export const DOCTORS_DATA = [
  { id: 1, name: 'dr. Andi Permadi Sp.M', spec: 'Spesialis Glaukoma', license: 'STR-12345-678', exp: '12 Tahun', fee: 'Rp 250.000', status: 'Aktif' },
  { id: 2, name: 'dr. Rani Wijaya Sp.M', spec: 'Oftalmologi Umum', license: 'STR-98765-432', exp: '8 Tahun', fee: 'Rp 200.000', status: 'Aktif' },
  { id: 3, name: 'dr. Lukman Sp.M', spec: 'Retina & Vitreous', license: 'STR-55443-221', exp: '15 Tahun', fee: 'Rp 300.000', status: 'Cuti' },
];

export const APPOINTMENTS_DATA = [
  { id: 1, patient: 'Agus Santoso', doctor: 'dr. Andi Permadi', date: '2023-10-25', time: '09:00', status: 'confirmed', payment: 'paid' },
  { id: 2, patient: 'Sari Mulyani', doctor: 'dr. Rani Wijaya', date: '2023-10-25', time: '10:30', status: 'pending_confirmation', payment: 'paid' },
  { id: 3, patient: 'Budi Hartono', doctor: 'dr. Andi Permadi', date: '2023-10-26', time: '14:00', status: 'pending_payment', payment: 'pending' },
  { id: 4, patient: 'Dewi Lestari', doctor: 'dr. Rani Wijaya', date: '2023-10-22', time: '08:30', status: 'completed', payment: 'paid' },
  { id: 5, patient: 'Hendrik', doctor: 'dr. Andi Permadi', date: '2023-10-24', time: '11:00', status: 'cancelled', payment: 'refunded' },
  ...Array(5).fill(null).map((_, i) => ({
    id: i + 6,
    patient: `Pasien Antrean ${i + 6}`,
    doctor: 'dr. Andi Permadi',
    date: '2023-10-27',
    time: '09:00',
    status: 'confirmed',
    payment: 'paid',
  })),
];

export const ML_MODELS_DATA = [
  { version: 'v2.1.0', arch: 'EfficientNetB4', dataset: 'EyeDataset v3', accuracy: '95.23%', auc: '0.9812', f1: '0.945', status: 'AKTIF', deploy: '1 Jan 2025' },
  { version: 'v2.0.0', arch: 'EfficientNetB0', dataset: 'EyeDataset v2', accuracy: '94.10%', auc: '0.9705', f1: '0.928', status: 'Nonaktif', deploy: '15 Okt 2024' },
  { version: 'v1.5.0', arch: 'ResNet50', dataset: 'EyeDataset v2', accuracy: '91.20%', auc: '0.9411', f1: '0.892', status: 'Nonaktif', deploy: '10 Jun 2024' },
  { version: 'v1.0.0', arch: 'VGG16', dataset: 'EyeDataset v1', accuracy: '88.50%', auc: '0.9100', f1: '0.850', status: 'Nonaktif', deploy: '01 Jan 2024' },
];

export const ACTIVITY_LOGS_DATA = [
  { id: 1, time: '2 menit lalu', user: 'Admin Sistem', role: 'ADMIN', module: 'Auth', action: 'Login', desc: 'Admin login ke dashboard', ip: '192.168.1.1' },
  { id: 2, time: '15 menit lalu', user: 'dr. Andi Permadi', role: 'DOKTER', module: 'Examination', action: 'Create', desc: 'Melakukan pemeriksaan pada pasien Budi Santoso', ip: '192.168.1.5' },
  { id: 3, time: '1 jam lalu', user: 'Admin Sistem', role: 'ADMIN', module: 'ML', action: 'Update', desc: 'Mengubah status model v2.1.0 menjadi Aktif', ip: '192.168.1.1' },
  { id: 4, time: '2 jam lalu', user: 'Siti Aminah', role: 'PASIEN', module: 'Appointment', action: 'Create', desc: 'Membuat janji temu untuk 25 Okt 2023', ip: '114.122.1.88' },
  { id: 5, time: '5 jam lalu', user: 'Admin Sistem', role: 'ADMIN', module: 'User', action: 'Delete', desc: 'Menghapus user id 445 (Tester)', ip: '192.168.1.1' },
  ...Array(10).fill(null).map((_, i) => ({
    id: i + 6,
    time: `${i + 6} jam lalu`,
    user: 'Sistem',
    role: 'ADMIN',
    module: 'Admin',
    action: 'System',
    desc: 'Daily backup database berhasil dilakukan',
    ip: '127.0.0.1',
  })),
];
