import { useState } from 'react';
import { Plus } from 'lucide-react';

import Badge from '../components/Badge';
import Modal from '../components/Modal';
import { DOCTORS_DATA } from '../data/dummy';

const DoctorPage = () => {
  const [tab, setTab] = useState('list');
  const [showAddModal, setShowAddModal] = useState(false);

  return (
    <div className="space-y-6">
      {/* Tabs */}
      <div className="flex border-b border-gray-200">
        {['list', 'schedule'].map((t) => (
          <button
            key={t}
            onClick={() => setTab(t)}
            className={`px-8 py-4 font-bold transition-all border-b-2 ${
              tab === t
                ? 'border-blue-600 text-blue-600'
                : 'border-transparent text-gray-400 hover:text-gray-600'
            }`}
          >
            {t === 'list' ? 'Daftar Dokter' : 'Jadwal Praktik'}
          </button>
        ))}
      </div>

      {/* List tab */}
      {tab === 'list' && (
        <div className="animate-in slide-in-from-left duration-300">
          <div className="flex justify-between items-center mb-6">
            <h3 className="text-xl font-bold text-gray-800">
              Total Dokter: {DOCTORS_DATA.length}
            </h3>
            <button
              onClick={() => setShowAddModal(true)}
              className="bg-blue-600 text-white px-4 py-2 rounded-lg flex items-center gap-2 hover:bg-blue-700 transition-all font-bold"
            >
              <Plus size={20} /> Tambah Dokter
            </button>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {DOCTORS_DATA.map((doc) => (
              <div
                key={doc.id}
                className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex flex-col items-center text-center"
              >
                <div className="w-24 h-24 rounded-full bg-blue-50 text-blue-600 flex items-center justify-center text-3xl font-bold mb-4 ring-4 ring-blue-50 border border-white">
                  {doc.name.charAt(4)}
                </div>
                <h4 className="font-bold text-lg text-gray-800">{doc.name}</h4>
                <p className="text-blue-600 text-sm mb-4">{doc.spec}</p>
                <div className="w-full space-y-2 text-sm text-gray-500 mb-6">
                  <div className="flex justify-between">
                    <span>Lisensi</span> <span className="text-gray-800">{doc.license}</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Pengalaman</span> <span className="text-gray-800">{doc.exp}</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Biaya</span> <span className="text-gray-800 font-bold">{doc.fee}</span>
                  </div>
                </div>
                <div className="flex gap-2 w-full">
                  <button className="flex-1 py-2 border border-blue-600 text-blue-600 rounded-lg hover:bg-blue-50 font-bold">
                    Edit
                  </button>
                  <button className="flex-1 py-2 bg-gray-50 text-gray-600 rounded-lg hover:bg-gray-100 font-bold">
                    Lihat Jadwal
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Schedule tab */}
      {tab === 'schedule' && (
        <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 animate-in slide-in-from-right duration-300">
          <div className="flex justify-between items-center mb-6">
            <select className="px-4 py-2 rounded-lg border border-gray-200 min-w-[300px] outline-none font-medium">
              <option>Pilih Dokter: dr. Andi Permadi Sp.M</option>
              <option>Pilih Dokter: dr. Rani Wijaya Sp.M</option>
            </select>
            <button className="bg-blue-600 text-white px-4 py-2 rounded-lg flex items-center gap-2 hover:bg-blue-700 transition-all font-bold">
              <Plus size={20} /> Tambah Jadwal
            </button>
          </div>
          <table className="w-full text-left">
            <thead className="bg-gray-50 text-gray-500 text-xs font-bold uppercase">
              <tr>
                <th className="px-6 py-4">Hari</th>
                <th className="px-6 py-4">Jam Mulai</th>
                <th className="px-6 py-4">Jam Selesai</th>
                <th className="px-6 py-4 text-center">Kuota</th>
                <th className="px-6 py-4">Status</th>
                <th className="px-6 py-4 text-right">Aksi</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {['Senin', 'Selasa', 'Kamis', 'Jumat', 'Sabtu'].map((day, idx) => (
                <tr key={idx} className="hover:bg-gray-50">
                  <td className="px-6 py-4 font-bold">{day}</td>
                  <td className="px-6 py-4">08:00</td>
                  <td className="px-6 py-4">12:00</td>
                  <td className="px-6 py-4 text-center">15 Pasien</td>
                  <td className="px-6 py-4">
                    <Badge variant="active">Buka</Badge>
                  </td>
                  <td className="px-6 py-4 text-right flex justify-end gap-2">
                    <button className="text-blue-600 hover:underline font-bold">Edit</button>
                    <button className="text-red-600 hover:underline font-bold">Hapus</button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* Add doctor modal */}
      <Modal
        isOpen={showAddModal}
        onClose={() => setShowAddModal(false)}
        title="Tambah Dokter Baru"
        footer={
          <>
            <button
              onClick={() => setShowAddModal(false)}
              className="px-4 py-2 text-gray-500 font-semibold"
            >
              Batal
            </button>
            <button className="px-6 py-2 bg-blue-600 text-white rounded-lg font-bold">
              Simpan Dokter
            </button>
          </>
        }
      >
        <div className="grid grid-cols-2 gap-4">
          <div className="col-span-2">
            <label className="block text-sm font-bold text-gray-700 mb-1">Nama Lengkap</label>
            <input
              type="text"
              className="w-full px-4 py-2 rounded-lg border border-gray-200"
              placeholder="Contoh: dr. Nama Lengkap Sp.M"
            />
          </div>
          <div>
            <label className="block text-sm font-bold text-gray-700 mb-1">Email</label>
            <input
              type="email"
              className="w-full px-4 py-2 rounded-lg border border-gray-200"
              placeholder="email@rsmata.com"
            />
          </div>
          <div>
            <label className="block text-sm font-bold text-gray-700 mb-1">Password</label>
            <input
              type="password"
              defaultValue="rsmata123"
              className="w-full px-4 py-2 rounded-lg border border-gray-200 bg-gray-50"
              readOnly
            />
          </div>
          <div>
            <label className="block text-sm font-bold text-gray-700 mb-1">Spesialisasi</label>
            <select className="w-full px-4 py-2 rounded-lg border border-gray-200">
              <option>Glaukoma</option>
              <option>Retina</option>
              <option>Kornea</option>
            </select>
          </div>
          <div>
            <label className="block text-sm font-bold text-gray-700 mb-1">No. Lisensi (STR)</label>
            <input type="text" className="w-full px-4 py-2 rounded-lg border border-gray-200" />
          </div>
          <div>
            <label className="block text-sm font-bold text-gray-700 mb-1">
              Pengalaman (Tahun)
            </label>
            <input
              type="number"
              className="w-full px-4 py-2 rounded-lg border border-gray-200"
            />
          </div>
          <div>
            <label className="block text-sm font-bold text-gray-700 mb-1">Biaya Konsultasi</label>
            <input
              type="number"
              className="w-full px-4 py-2 rounded-lg border border-gray-200"
              placeholder="200000"
            />
          </div>
          <div className="col-span-2">
            <label className="block text-sm font-bold text-gray-700 mb-1">Bio Ringkas</label>
            <textarea className="w-full px-4 py-2 rounded-lg border border-gray-200 h-24" />
          </div>
        </div>
      </Modal>
    </div>
  );
};

export default DoctorPage;
