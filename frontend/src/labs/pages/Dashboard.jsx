import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  ChevronRight, Info, Loader2, MoreVertical, 
  Users, Activity, AlertCircle, Target, 
  ArrowUpRight, ArrowDownRight, Clock
} from 'lucide-react';
import StatCard from '../components/StatCard';
import axios from '../../utils/axios';

// Mapping string dari API ke Komponen Ikon
const IconMap = {
  Users: Users,
  Activity: Activity,
  AlertCircle: AlertCircle,
  Target: Target
};

const Dashboard = () => {
  const navigate = useNavigate();
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchDashboard = async () => {
      try {
        const response = await axios.get('http://localhost:8000/api/labs/dashboard')
        if (response.data) {
          setData(response.data);
        }
      
      } catch (error) {
        console.error("Gagal load dashboard:", error);
      } finally {
        setLoading(false);
      }
    };
    fetchDashboard();
  }, []);

  if (loading) {
    return (
      <div className="h-[80vh] flex flex-col items-center justify-center text-[#1565C0]">
        <Loader2 className="animate-spin mb-4" size={48} />
        <p className="font-bold text-lg">Menghubungkan ke Database...</p>
      </div>
    );
  }

  return (
    <div className="animate-in fade-in duration-500 pb-10">
      {/* Header */}
      <div className="mb-8 flex justify-between items-end">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 tracking-tight">Ringkasan Aktivitas</h1>
          <p className="text-gray-500">Selamat pagi, <span className="font-semibold text-gray-700">dr. Budi Santoso</span></p>
        </div>
        <div className="text-[10px] font-black text-gray-400 bg-gray-100 px-4 py-2 rounded-2xl border border-gray-200 uppercase tracking-widest">
          Update: Baru Saja
        </div>
      </div>

      {/* Stat Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-10">
        {data?.stats.map((stat, i) => {
          const IconComponent = IconMap[stat.icon] || Activity;
          return (
            <StatCard 
              key={i} 
              title={stat.label} 
              value={stat.value} 
              // Kirim sebagai Elemen JSX
              icon={<IconComponent size={24} />} 
              trend={stat.trend} 
            />
          );
        })}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Kolom Kiri: Tabel Pasien */}
        <div className="lg:col-span-2 space-y-8">
          <div className="bg-white rounded-[32px] shadow-sm border border-gray-100 overflow-hidden">
            <div className="p-6 border-b border-gray-50 flex justify-between items-center bg-white">
              <div className="flex items-center gap-3">
                <h2 className="font-bold text-gray-900">Pasien Siap Diperiksa</h2>
                <span className="bg-blue-50 text-blue-600 text-[10px] font-black px-2 py-1 rounded-md uppercase tracking-tighter">
                  {data?.ready_to_exam.length} Antrian
                </span>
              </div>
              <button className="text-[#1565C0] text-sm font-bold hover:underline">Lihat Semua</button>
            </div>
            
            <div className="overflow-x-auto">
              <table className="w-full text-left">
                <thead>
                  <tr className="bg-gray-50/50 text-gray-400 text-[10px] uppercase tracking-[0.2em] font-black">
                    <th className="px-6 py-5">Pasien</th>
                    <th className="px-6 py-5">Jam Janji</th>
                    <th className="px-6 py-5">Keluhan</th>
                    <th className="px-6 py-5 text-right">Aksi</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-50">
                  {data?.ready_to_exam.length > 0 ? (
                    data.ready_to_exam.map((pasien) => (
                      <tr key={pasien.id} className="hover:bg-blue-50/30 transition-all group">
                        <td className="px-6 py-5">
                          <div className="flex flex-col">
                            <span className="font-bold text-gray-900 text-sm">{pasien.name}</span>
                            <span className="text-[10px] text-gray-400 font-bold uppercase">ID: #PX-{pasien.id}</span>
                          </div>
                        </td>
                        <td className="px-6 py-5">
                          <div className="flex items-center gap-2 text-gray-600 text-sm font-medium">
                            <Clock size={14} className="text-blue-500" /> {pasien.time}
                          </div>
                        </td>
                        <td className="px-6 py-5 text-gray-500 text-sm italic truncate max-w-[150px]">
                          "{pasien.complain}"
                        </td>
                        <td className="px-6 py-5 text-right">
                          <button
                            onClick={() => navigate(`/labs/pemeriksaan?appointment_id=${pasien.id}`)}
                            className="bg-[#1565C0] text-white px-5 py-2.5 rounded-2xl text-xs font-bold hover:bg-blue-700 transition-all flex items-center gap-2 ml-auto"
                          >
                            Periksa <ChevronRight size={14} />
                          </button>
                        </td>
                      </tr>
                    ))
                  ) : (
                    <tr>
                      <td colSpan="4" className="px-6 py-10 text-center text-gray-400 italic text-sm">
                        Belum ada antrian pasien untuk hari ini.
                      </td>
                    </tr>
                  )}
                </tbody>
              </table>
            </div>
          </div>
        </div>

        {/* Kolom Kanan: Sidebar */}
        <div className="space-y-6">
          {/* Proses ML */}
          <div className="bg-white p-6 rounded-[32px] shadow-sm border border-gray-100">
            <h2 className="font-bold text-gray-900 mb-6">Sedang Diproses ML</h2>
            <div className="space-y-4">
              {data?.processing.length > 0 ? (
                data.processing.map((item, i) => (
                  <div key={i} className="flex items-center gap-4 p-4 rounded-3xl bg-gray-50 border border-gray-100">
                    <div className="w-10 h-10 rounded-2xl bg-blue-100 flex items-center justify-center text-[#1565C0]">
                      <Loader2 size={20} className="animate-spin" />
                    </div>
                    <div className="flex-1">
                      <p className="font-bold text-gray-900 text-sm">{item.name}</p>
                      <p className="text-[10px] text-gray-500 font-bold uppercase tracking-widest">{item.time}</p>
                    </div>
                  </div>
                ))
              ) : (
                <p className="text-center text-gray-400 text-xs py-4">Antrian pemrosesan kosong</p>
              )}
            </div>
          </div>

          {/* Tips Card */}
          <div className="bg-gradient-to-br from-[#1565C0] to-[#42A5F5] p-8 rounded-[32px] text-white relative overflow-hidden group shadow-xl shadow-blue-100">
            <div className="absolute -right-4 -bottom-4 opacity-10 group-hover:scale-110 transition-transform duration-700">
                <Target size={140} />
            </div>
            <div className="p-3 bg-white/20 rounded-2xl w-fit mb-6 backdrop-blur-sm">
                <Info size={24} />
            </div>
            <h3 className="text-lg font-bold mb-2">Tips Diagnosis</h3>
            <p className="text-sm text-white/80 leading-relaxed mb-6 font-medium">
              Pastikan kualitas gambar fundus optimal (pencahayaan merata) untuk mendapatkan akurasi AI di atas 95%.
            </p>
            <button
              onClick={() => {
                window.location.href = "https://www.apollohospitals.com/id/diagnostics-investigations/fundus-photography";
              }}
             className="w-full py-4 bg-white text-[#1565C0] rounded-2xl text-xs font-black uppercase tracking-widest hover:bg-gray-50 transition-all shadow-md">
              Lihat Panduan
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;