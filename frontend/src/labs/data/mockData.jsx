import { ClipboardList, Clock, Loader2, CheckCircle } from 'lucide-react';

export const dashboardStats = [
  { title: 'Total Hari Ini', value: 12, color: 'bg-blue-600', icon: ClipboardList },
  { title: 'Menunggu Diproses', value: 3, color: 'bg-orange-500', icon: Clock },
  { title: 'Sedang Diproses ML', value: 2, color: 'bg-yellow-500', icon: Loader2 },
  { title: 'Selesai', value: 7, color: 'bg-green-600', icon: CheckCircle },
];

export const readyToExam = [
  { id: 1, name: 'Budi Santoso', time: '09:15', complain: 'Mata kabur di malam hari', status: 'Menunggu' },
  { id: 2, name: 'Siti Aminah', time: '10:00', complain: 'Nyeri pada bola mata', status: 'Menunggu' },
  { id: 3, name: 'Rahmat Hidayat', time: '10:45', complain: 'Pandangan menyempit', status: 'Menunggu' },
  { id: 4, name: 'Dewi Lestari', time: '11:30', complain: 'Sakit kepala hebat & mual', status: 'Menunggu' },
  { id: 5, name: 'Agus Setiawan', time: '13:00', complain: 'Pemeriksaan rutin', status: 'Menunggu' },
];

export const historyData = [
  { id: 101, name: 'Andi Wijaya', date: '2025-03-01', eye: 'Kiri', result: 'NORMAL', conf: 92, doctor: 'dr. Budi Santoso' },
  { id: 102, name: 'Ratna Sari', date: '2025-03-01', eye: 'Keduanya', result: 'GLAUKOMA', conf: 88, doctor: 'dr. Budi Santoso' },
  { id: 103, name: 'Bambang U.', date: '2025-02-28', eye: 'Kanan', result: 'NORMAL', conf: 95, doctor: 'dr. Budi Santoso' },
  { id: 104, name: 'Lina Marlina', date: '2025-02-28', eye: 'Kiri', result: 'GLAUKOMA', conf: 76, doctor: 'dr. Budi Santoso' },
  { id: 105, name: 'Eko Prasetyo', date: '2025-02-27', eye: 'Keduanya', result: 'NORMAL', conf: 89, doctor: 'dr. Budi Santoso' },
  { id: 106, name: 'Indah Permata', date: '2025-02-27', eye: 'Kanan', result: 'NORMAL', conf: 91, doctor: 'dr. Budi Santoso' },
  { id: 107, name: 'Doni Salman', date: '2025-02-26', eye: 'Kiri', result: 'GLAUKOMA', conf: 94, doctor: 'dr. Budi Santoso' },
  { id: 108, name: 'Yanti Rossi', date: '2025-02-26', eye: 'Keduanya', result: 'NORMAL', conf: 90, doctor: 'dr. Budi Santoso' },
  { id: 109, name: 'Kurniawan', date: '2025-02-25', eye: 'Kiri', result: 'NORMAL', conf: 87, doctor: 'dr. Budi Santoso' },
  { id: 110, name: 'Siska Putri', date: '2025-02-25', eye: 'Kanan', result: 'GLAUKOMA', conf: 82, doctor: 'dr. Budi Santoso' },
];