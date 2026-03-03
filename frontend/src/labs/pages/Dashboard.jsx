import { useNavigate } from 'react-router-dom';
import { ChevronRight, Info, Loader2, MoreVertical } from 'lucide-react';
import StatCard from '../components/StatCard';
import { dashboardStats, readyToExam } from '../data/mockData';

const Dashboard = () => {
  const navigate = useNavigate();
  return (
    <div className="animate-in fade-in duration-500">
      <div className="mb-8">
        <h1 className="text-2xl font-bold text-gray-900">Ringkasan Aktivitas</h1>
        <p className="text-gray-500">Selamat pagi, dr. Budi Santoso</p>
      </div>

      {/* Stat Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-10">
        {dashboardStats.map((stat, i) => (
          <StatCard key={i} {...stat} />
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Pasien Table */}
        <div className="lg:col-span-2 space-y-8">
          <div className="bg-white rounded-3xl shadow-sm border border-gray-100 overflow-hidden">
            <div className="p-6 border-b border-gray-50 flex justify-between items-center">
              <h2 className="font-bold text-gray-900">Pasien Siap Diperiksa</h2>
              <button className="text-blue-600 text-sm font-semibold hover:underline">Lihat Semua</button>
            </div>
            <div className="overflow-x-auto">
              <table className="w-full text-left">
                <thead>
                  <tr className="bg-gray-50/50 text-gray-400 text-xs uppercase tracking-wider">
                    <th className="px-6 py-4 font-semibold">Pasien</th>
                    <th className="px-6 py-4 font-semibold">Jam</th>
                    <th className="px-6 py-4 font-semibold">Keluhan Utama</th>
                    <th className="px-6 py-4 font-semibold">Status</th>
                    <th className="px-6 py-4 font-semibold text-right">Aksi</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-50">
                  {readyToExam.map((pasien) => (
                    <tr key={pasien.id} className="hover:bg-blue-50/30 transition-colors">
                      <td className="px-6 py-4 font-medium text-gray-900">{pasien.name}</td>
                      <td className="px-6 py-4 text-gray-500">{pasien.time}</td>
                      <td className="px-6 py-4 text-gray-600 italic">"{pasien.complain}"</td>
                      <td className="px-6 py-4">
                        <span className="px-3 py-1 rounded-full text-xs font-semibold bg-orange-100 text-orange-600">
                          {pasien.status}
                        </span>
                      </td>
                      <td className="px-6 py-4 text-right">
                        <button
                          onClick={() => navigate('/pemeriksaan')}
                          className="bg-[#1565C0] text-white px-4 py-2 rounded-xl text-sm font-medium hover:bg-blue-700 transition-all flex items-center gap-2 ml-auto"
                        >
                          Periksa <ChevronRight size={16} />
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>

        {/* Right Sidebar Cards */}
        <div className="space-y-6">
          {/* ML Processing Card */}
          <div className="bg-white p-6 rounded-3xl shadow-sm border border-gray-100">
            <h2 className="font-bold text-gray-900 mb-4">Sedang Diproses ML</h2>
            <div className="space-y-4">
              {[
                { name: 'Rudy Hartono', time: '1 menit lalu' },
                { name: 'Maya Sari', time: 'Baru saja' },
              ].map((item, i) => (
                <div key={i} className="flex items-center gap-4 p-4 rounded-2xl bg-gray-50 border border-gray-100">
                  <div className="w-10 h-10 rounded-full bg-blue-100 flex items-center justify-center text-blue-600">
                    <Loader2 size={20} className="animate-spin" />
                  </div>
                  <div className="flex-1">
                    <p className="font-semibold text-gray-900 text-sm">{item.name}</p>
                    <p className="text-xs text-gray-500">{item.time}</p>
                  </div>
                  <div className="text-[10px] font-bold text-blue-600 px-2 py-1 rounded bg-blue-50 border border-blue-100">
                    PROCESSING
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Tips Card */}
          <div className="bg-gradient-to-br from-[#1565C0] to-[#42A5F5] p-6 rounded-3xl text-white">
            <div className="flex justify-between items-start mb-4">
              <Info size={24} />
              <button className="text-white/60 hover:text-white">
                <MoreVertical size={20} />
              </button>
            </div>
            <h3 className="text-lg font-bold mb-2">Tips Hari Ini</h3>
            <p className="text-sm text-white/80 leading-relaxed mb-4">
              Pastikan kualitas gambar fundus optimal (pencahayaan merata) untuk mendapatkan akurasi AI di atas 95%.
            </p>
            <button className="w-full py-2 bg-white/20 hover:bg-white/30 rounded-xl text-sm font-semibold transition-all">
              Pelajari Panduan
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;