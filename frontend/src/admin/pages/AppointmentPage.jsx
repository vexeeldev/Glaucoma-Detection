import { useState } from 'react';
import { Search, CalendarDays } from 'lucide-react';

import Badge from '../components/Badge';
import Modal from '../components/Modal';
import { APPOINTMENTS_DATA } from '../data/dummy';

const getStatusBadge = (status) => {
  switch (status) {
    case 'confirmed':            return <Badge variant="confirmed">Confirmed</Badge>;
    case 'pending_payment':      return <Badge variant="default">Pending Payment</Badge>;
    case 'pending_confirmation': return <Badge variant="pending">Pending Confirmation</Badge>;
    case 'completed':            return <Badge variant="active">Completed</Badge>;
    case 'cancelled':            return <Badge variant="inactive">Cancelled</Badge>;
    case 'rejected':             return <Badge variant="inactive">Rejected</Badge>;
    default:                     return <Badge variant="default">{status}</Badge>;
  }
};

const AppointmentPage = () => {
  const [activeModal, setActiveModal] = useState(null);

  return (
    <div className="space-y-6">
      {/* Filters */}
      <div className="bg-white p-4 rounded-xl shadow-sm border border-gray-100 flex flex-wrap gap-4 items-center">
        <div className="flex gap-2 items-center bg-gray-50 px-3 py-2 rounded-lg border border-gray-200">
          <CalendarDays size={18} className="text-gray-400" />
          <input type="date" className="bg-transparent outline-none text-sm font-medium" />
        </div>
        <div className="relative flex-1 min-w-[200px]">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
          <input
            type="text"
            placeholder="Cari nama pasien atau dokter..."
            className="w-full pl-10 pr-4 py-2 rounded-lg border border-gray-200 outline-none focus:border-blue-500"
          />
        </div>
        <select className="px-4 py-2 rounded-lg border border-gray-200 outline-none">
          <option>Semua Status</option>
          <option>Pending Payment</option>
          <option>Confirmed</option>
          <option>Completed</option>
        </select>
      </div>

      {/* Table */}
      <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
        <table className="w-full text-left">
          <thead className="bg-gray-50 text-gray-500 text-xs font-bold uppercase">
            <tr>
              <th className="px-6 py-4">No</th>
              <th className="px-6 py-4">Pasien</th>
              <th className="px-6 py-4">Dokter</th>
              <th className="px-6 py-4">Waktu</th>
              <th className="px-6 py-4 text-center">Status</th>
              <th className="px-6 py-4 text-center">Pembayaran</th>
              <th className="px-6 py-4 text-right">Aksi</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-100">
            {APPOINTMENTS_DATA.map((apt, idx) => (
              <tr key={apt.id} className="hover:bg-gray-50">
                <td className="px-6 py-4 text-gray-500">{idx + 1}</td>
                <td className="px-6 py-4 font-bold text-gray-800">{apt.patient}</td>
                <td className="px-6 py-4 text-gray-600">{apt.doctor}</td>
                <td className="px-6 py-4">
                  <div className="text-sm font-bold text-gray-800">{apt.date}</div>
                  <div className="text-xs text-gray-400">{apt.time} WIB</div>
                </td>
                <td className="px-6 py-4 text-center">{getStatusBadge(apt.status)}</td>
                <td className="px-6 py-4 text-center">
                  <span
                    className={`text-[10px] font-black uppercase ${
                      apt.payment === 'paid' ? 'text-green-600' : 'text-gray-400'
                    }`}
                  >
                    ● {apt.payment}
                  </span>
                </td>
                <td className="px-6 py-4 text-right">
                  <button
                    onClick={() => setActiveModal(apt)}
                    className="text-blue-600 hover:underline font-bold text-sm"
                  >
                    Lihat Detail
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Detail modal */}
      <Modal
        isOpen={!!activeModal}
        onClose={() => setActiveModal(null)}
        title="Detail Appointment"
      >
        {activeModal && (
          <div className="space-y-6">
            <div className="grid grid-cols-2 gap-4">
              <div className="bg-gray-50 p-4 rounded-xl border">
                <p className="text-xs text-gray-400 uppercase font-bold mb-1">
                  Informasi Pasien
                </p>
                <p className="font-bold text-gray-800">{activeModal.patient}</p>
                <p className="text-sm text-gray-500">
                  Keluhan: Penglihatan sering buram dan sakit kepala
                </p>
              </div>
              <div className="bg-gray-50 p-4 rounded-xl border">
                <p className="text-xs text-gray-400 uppercase font-bold mb-1">
                  Informasi Dokter
                </p>
                <p className="font-bold text-gray-800">{activeModal.doctor}</p>
                <p className="text-sm text-gray-500">RS Mata Jakarta - Lantai 2</p>
              </div>
            </div>

            <div>
              <p className="text-sm font-bold mb-3">Timeline Status</p>
              <div className="space-y-4">
                {[
                  { step: 1, title: 'Booking Dibuat',             time: '24 Okt 2023 - 10:00' },
                  { step: 2, title: 'Pembayaran Diverifikasi',    time: '24 Okt 2023 - 10:15' },
                  { step: 3, title: 'Menunggu Konfirmasi Dokter', time: 'Status saat ini' },
                ].map(({ step, title, time }) => (
                  <div key={step} className="flex gap-3">
                    <div className={`w-8 h-8 rounded-full flex items-center justify-center shrink-0 ${step < 3 ? 'bg-green-100 text-green-600' : 'bg-blue-100 text-blue-600'}`}>
                      {step}
                    </div>
                    <div>
                      <p className="text-sm font-bold">{title}</p>
                      <p className="text-xs text-gray-400">{time}</p>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            <div className="p-4 border border-blue-100 bg-blue-50 rounded-xl">
              <h4 className="text-sm font-bold text-blue-800 mb-2">Informasi Pembayaran</h4>
              <div className="flex justify-between text-sm">
                <span className="text-blue-600">ID Invoice</span>
                <span className="font-mono font-bold">INV/20231024/001</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-blue-600">Nominal</span>
                <span className="font-bold">Rp 255.000</span>
              </div>
            </div>
          </div>
        )}
      </Modal>
    </div>
  );
};

export default AppointmentPage;
