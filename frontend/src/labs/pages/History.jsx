import { useState } from 'react';
import {
  Search, Calendar, Filter, ChevronRight, FileText,
  Download, LogOut, Eye as EyeIcon,
} from 'lucide-react';
import { historyData } from '../data/mockData';

const HistoryDetailModal = ({ data, onClose }) => (
  <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
    <div
      className="absolute inset-0 bg-blue-900/60 backdrop-blur-sm"
      onClick={onClose}
    ></div>
    <div className="bg-white w-full max-w-4xl rounded-[32px] shadow-2xl relative overflow-hidden flex flex-col max-h-[90vh] animate-in zoom-in-95 duration-300">
      {/* Modal Header */}
      <div className="p-8 border-b border-gray-100 flex justify-between items-center">
        <div>
          <p className="text-xs font-black text-blue-600 uppercase tracking-widest mb-1">
            Arsip Medis #{data.id}
          </p>
          <h2 className="text-2xl font-bold text-gray-900">{data.name}</h2>
        </div>
        <button
          onClick={onClose}
          className="p-2 hover:bg-gray-100 rounded-full text-gray-400"
        >
          <LogOut className="rotate-180" size={24} />
        </button>
      </div>

      {/* Modal Body */}
      <div className="p-8 overflow-y-auto flex-1 bg-gray-50/50">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Left: Analisis + Diagnosis */}
          <div className="lg:col-span-2 space-y-8">
            {/* Analisis AI */}
            <div className="bg-white p-6 rounded-3xl border border-gray-100 shadow-sm">
              <h3 className="font-bold text-gray-900 mb-6 flex items-center gap-2">
                <EyeIcon size={20} className="text-blue-600" /> Hasil Analisis AI
              </h3>
              <div className="flex gap-6 items-center">
                <div
                  className={`p-6 rounded-2xl flex flex-col items-center justify-center min-w-[160px] ${
                    data.result === 'NORMAL'
                      ? 'bg-green-50 text-green-700 border border-green-100'
                      : 'bg-red-50 text-red-700 border border-red-100'
                  }`}
                >
                  <p className="text-[10px] font-black uppercase mb-1 opacity-50">Status</p>
                  <span className="text-2xl font-black">{data.result}</span>
                </div>
                <div className="flex-1">
                  <div className="flex justify-between mb-2">
                    <span className="text-sm font-bold text-gray-500">Confidence Score</span>
                    <span className="text-sm font-black text-gray-900">{data.conf}%</span>
                  </div>
                  <div className="h-3 bg-gray-100 rounded-full overflow-hidden">
                    <div
                      className={`h-full ${data.result === 'NORMAL' ? 'bg-green-500' : 'bg-red-500'}`}
                      style={{ width: `${data.conf}%` }}
                    ></div>
                  </div>
                </div>
              </div>

              <div className="mt-8 grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <img
                    src="https://picsum.photos/seed/hist1/400"
                    className="w-full aspect-video object-cover rounded-2xl border border-gray-100"
                    alt="Fundus"
                  />
                  <p className="text-[10px] text-center font-bold text-gray-400">FUNDUS PHOTOGRAPH</p>
                </div>
                <div className="space-y-2">
                  <div className="relative rounded-2xl overflow-hidden border border-gray-100">
                    <img
                      src="https://picsum.photos/seed/hist2/400"
                      className="w-full aspect-video object-cover opacity-60"
                      alt="Heatmap"
                    />
                    <div className="absolute inset-0 bg-gradient-to-tr from-blue-500/30 to-red-500/50 mix-blend-overlay"></div>
                  </div>
                  <p className="text-[10px] text-center font-bold text-gray-400">GRAD-CAM HEATMAP</p>
                </div>
              </div>
            </div>

            {/* Diagnosis Dokter */}
            <div className="bg-white p-6 rounded-3xl border border-gray-100 shadow-sm">
              <h3 className="font-bold text-gray-900 mb-4 flex items-center gap-2">
                <FileText size={20} className="text-blue-600" /> Diagnosis Dokter
              </h3>
              <div className="p-5 bg-blue-50/50 border border-blue-100 rounded-2xl text-blue-900 italic text-sm leading-relaxed">
                "Berdasarkan analisis AI dan pemeriksaan fisik, struktur saraf mata masih dalam batas normal.
                Namun, terdapat riwayat keluarga glaukoma. Disarankan kontrol rutin 6 bulan sekali dan menjaga
                pola makan sehat."
              </div>
              <div className="mt-4 flex justify-between items-center text-xs">
                <span className="text-gray-400">Terakhir diperbarui: 03/03/2025</span>
                <span className="font-bold text-blue-600 underline cursor-pointer">Edit Diagnosis</span>
              </div>
            </div>
          </div>

          {/* Right: Info Pasien + Aksi */}
          <div className="space-y-6">
            <div className="bg-white p-6 rounded-3xl border border-gray-100 shadow-sm">
              <h3 className="text-xs font-black text-gray-400 uppercase tracking-widest mb-4">Info Pasien</h3>
              <div className="space-y-4">
                {[
                  { label: 'Nama', value: data.name },
                  { label: 'Tanggal Pemeriksaan', value: data.date },
                  { label: 'Mata', value: data.eye },
                  { label: 'Dokter Pemeriksa', value: data.doctor },
                ].map(({ label, value }) => (
                  <div key={label}>
                    <p className="text-[10px] text-gray-400 font-bold uppercase">{label}</p>
                    <p className="font-bold text-gray-900">{value}</p>
                  </div>
                ))}
              </div>
            </div>

            <button className="w-full py-4 bg-green-600 text-white rounded-2xl font-bold shadow-lg shadow-green-100 flex items-center justify-center gap-2 hover:bg-green-700 transition-all">
              <Download size={20} /> Download Report (PDF)
            </button>
            <button className="w-full py-4 bg-gray-100 text-gray-500 rounded-2xl font-bold hover:bg-gray-200 transition-all">
              Cetak Label Fisik
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
);

const History = () => {
  const [selectedHistory, setSelectedHistory] = useState(null);

  return (
    <div className="animate-in fade-in duration-500">
      <div className="flex justify-between items-end mb-8">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Riwayat Pemeriksaan</h1>
          <p className="text-gray-500">Arsip data medis dan hasil AI sebelumnya</p>
        </div>
        <button className="bg-green-600 text-white px-5 py-2.5 rounded-xl font-semibold flex items-center gap-2 hover:bg-green-700 transition-all shadow-lg shadow-green-100">
          <FileText size={18} /> Download Excel
        </button>
      </div>

      <div className="bg-white rounded-3xl shadow-sm border border-gray-100 overflow-hidden">
        {/* Filter Bar */}
        <div className="p-6 border-b border-gray-50 flex flex-wrap gap-4 items-center">
          <div className="relative flex-1 min-w-[300px]">
            <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
            <input
              type="text"
              placeholder="Cari nama pasien atau ID..."
              className="w-full pl-12 pr-4 py-2.5 rounded-xl border border-gray-200 outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div className="flex items-center gap-2">
            <div className="bg-gray-50 border border-gray-200 rounded-xl px-4 py-2.5 flex items-center gap-2 cursor-pointer hover:bg-gray-100 transition-all">
              <Calendar size={18} className="text-gray-400" />
              <span className="text-sm font-medium text-gray-600">Pilih Rentang Tanggal</span>
            </div>
            <div className="bg-gray-50 border border-gray-200 rounded-xl px-4 py-2.5 flex items-center gap-2 cursor-pointer hover:bg-gray-100 transition-all">
              <Filter size={18} className="text-gray-400" />
              <select className="bg-transparent text-sm font-medium text-gray-600 outline-none cursor-pointer">
                <option>Semua Hasil</option>
                <option>Normal</option>
                <option>Glaukoma</option>
              </select>
            </div>
          </div>
        </div>

        {/* Table */}
        <div className="overflow-x-auto">
          <table className="w-full text-left">
            <thead>
              <tr className="bg-gray-50/50 text-gray-400 text-xs uppercase tracking-wider">
                <th className="px-6 py-4 font-semibold text-center">No</th>
                <th className="px-6 py-4 font-semibold">Nama Pasien</th>
                <th className="px-6 py-4 font-semibold">Tanggal</th>
                <th className="px-6 py-4 font-semibold">Mata</th>
                <th className="px-6 py-4 font-semibold">Hasil AI</th>
                <th className="px-6 py-4 font-semibold">Confidence</th>
                <th className="px-6 py-4 font-semibold text-right">Aksi</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-50">
              {historyData.map((data, i) => (
                <tr key={data.id} className="hover:bg-blue-50/30 transition-colors group">
                  <td className="px-6 py-4 text-center text-gray-400 text-sm font-bold">{i + 1}</td>
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-3">
                      <div className="w-8 h-8 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center text-xs font-bold">
                        {data.name.split(' ').map((n) => n[0]).join('')}
                      </div>
                      <span className="font-bold text-gray-900">{data.name}</span>
                    </div>
                  </td>
                  <td className="px-6 py-4 text-gray-500 text-sm">{data.date}</td>
                  <td className="px-6 py-4 text-gray-600 text-sm">{data.eye}</td>
                  <td className="px-6 py-4">
                    <span
                      className={`px-3 py-1 rounded-full text-[10px] font-black tracking-widest ${
                        data.result === 'NORMAL' ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'
                      }`}
                    >
                      {data.result}
                    </span>
                  </td>
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-2">
                      <div className="flex-1 h-1.5 bg-gray-100 rounded-full min-w-[60px]">
                        <div
                          className={`h-full rounded-full ${data.conf > 90 ? 'bg-green-500' : 'bg-blue-500'}`}
                          style={{ width: `${data.conf}%` }}
                        ></div>
                      </div>
                      <span className="text-xs font-bold text-gray-700">{data.conf}%</span>
                    </div>
                  </td>
                  <td className="px-6 py-4 text-right">
                    <button
                      onClick={() => setSelectedHistory(data)}
                      className="bg-white border-2 border-gray-100 text-gray-600 px-3 py-1.5 rounded-xl text-xs font-bold hover:border-blue-500 hover:text-blue-500 transition-all"
                    >
                      Lihat Detail
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Pagination */}
        <div className="p-6 bg-gray-50 border-t border-gray-100 flex justify-between items-center">
          <p className="text-sm text-gray-500">
            Menampilkan <span className="font-bold text-gray-900">10</span> dari{' '}
            <span className="font-bold text-gray-900">142</span> data
          </p>
          <div className="flex gap-2">
            <button className="p-2 border border-gray-200 rounded-lg hover:bg-white text-gray-400 disabled:opacity-50" disabled>
              <ChevronRight size={18} className="rotate-180" />
            </button>
            <button className="px-3 py-1 bg-blue-600 text-white rounded-lg text-sm font-bold">1</button>
            <button className="px-3 py-1 hover:bg-white border border-transparent hover:border-gray-200 rounded-lg text-sm text-gray-600">2</button>
            <button className="px-3 py-1 hover:bg-white border border-transparent hover:border-gray-200 rounded-lg text-sm text-gray-600">3</button>
            <button className="p-2 border border-gray-200 rounded-lg hover:bg-white text-gray-400">
              <ChevronRight size={18} />
            </button>
          </div>
        </div>
      </div>

      {/* Modal */}
      {selectedHistory && (
        <HistoryDetailModal data={selectedHistory} onClose={() => setSelectedHistory(null)} />
      )}
    </div>
  );
};

export default History;