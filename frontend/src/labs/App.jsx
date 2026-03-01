import React, { useState, useEffect, useMemo } from 'react';
import { 
  LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
  PieChart, Pie, Cell, BarChart, Bar, Legend
} from 'recharts';
import { 
  Eye, LayoutDashboard, ClipboardList, History, LogOut, Search, 
  Upload, CheckCircle, AlertCircle, Clock, ChevronRight, 
  User, Calendar, Info, FileText, Download, EyeOff, EyeIcon, 
  MoreVertical, Filter, ArrowLeft, Loader2
} from 'lucide-react';


// --- STYLES & THEME ---
const COLORS = {
  primary: '#1565C0',
  secondary: '#42A5F5', 
  bg: '#F8FAFF',
  glaucoma: { text: '#C62828', bg: '#FFEBEE', hex: '#EF5350' },
  normal: { text: '#2E7D32', bg: '#E8F5E9', hex: '#66BB6A' },
  warning: '#FBC02D',
  orange: '#F57C00'
};

const App = () => {
  const [currentPage, setCurrentPage] = useState('login');
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [loading, setLoading] = useState(false);
  const [examStep, setExamStep] = useState(1);
  const [showPassword, setShowPassword] = useState(false);
  const [mlLoading, setMlLoading] = useState(false);
  const [uploadProgress, setUploadProgress] = useState(0);
  const [selectedResult, setSelectedResult] = useState('NORMAL'); // Toggle for demo
  const [selectedHistory, setSelectedHistory] = useState(null);

  // --- DUMMY DATA ---
  const dashboardStats = [
    { title: 'Total Hari Ini', value: 12, color: 'bg-blue-600', icon: ClipboardList },
    { title: 'Menunggu Diproses', value: 3, color: 'bg-orange-500', icon: Clock },
    { title: 'Sedang Diproses ML', value: 2, color: 'bg-yellow-500', icon: Loader2 },
    { title: 'Selesai', value: 7, color: 'bg-green-600', icon: CheckCircle },
  ];

  const readyToExam = [
    { id: 1, name: 'Budi Santoso', time: '09:15', complain: 'Mata kabur di malam hari', status: 'Menunggu' },
    { id: 2, name: 'Siti Aminah', time: '10:00', complain: 'Nyeri pada bola mata', status: 'Menunggu' },
    { id: 3, name: 'Rahmat Hidayat', time: '10:45', complain: 'Pandangan menyempit', status: 'Menunggu' },
    { id: 4, name: 'Dewi Lestari', time: '11:30', complain: 'Sakit kepala hebat & mual', status: 'Menunggu' },
    { id: 5, name: 'Agus Setiawan', time: '13:00', complain: 'Pemeriksaan rutin', status: 'Menunggu' },
  ];

  const historyData = [
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

  const pieData = selectedResult === 'NORMAL' 
    ? [{ name: 'Normal', value: 92 }, { name: 'Glaukoma', value: 8 }]
    : [{ name: 'Normal', value: 15 }, { name: 'Glaukoma', value: 85 }];

  // --- HANDLERS ---
  const handleLogin = (e) => {
    e.preventDefault();
    setLoading(true);
    setTimeout(() => {
      setLoading(false);
      setIsLoggedIn(true);
      setCurrentPage('dashboard');
    }, 1000);
  };

  const startExamination = () => {
    setCurrentPage('pemeriksaan');
    setExamStep(1);
  };

  const handleUpload = () => {
    let progress = 0;
    const interval = setInterval(() => {
      progress += 10;
      setUploadProgress(progress);
      if (progress >= 100) {
        clearInterval(interval);
        setExamStep(3);
        startMLAnalysis();
      }
    }, 200);
  };

  const startMLAnalysis = () => {
    setMlLoading(true);
    setTimeout(() => {
      setMlLoading(false);
    }, 3000);
  };

  const handleLogout = () => {
    setIsLoggedIn(false);
    setCurrentPage('login');
  };

  // --- COMPONENTS ---

  const Sidebar = () => (
    <div className="w-64 bg-[#1565C0] text-white flex flex-col h-screen fixed left-0 top-0 z-10">
      <div className="p-6 flex items-center gap-3 border-b border-blue-400/30">
        <div className="bg-white p-2 rounded-lg">
          <Eye className="text-[#1565C0]" size={24} />
        </div>
        <span className="text-xl font-bold tracking-tight">GlaucoScan</span>
      </div>
      
      <nav className="flex-1 mt-6 px-4">
        <ul className="space-y-2">
          <li>
            <button 
              onClick={() => setCurrentPage('dashboard')}
              className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl transition-all ${currentPage === 'dashboard' ? 'bg-white/20 font-semibold' : 'hover:bg-white/10 opacity-80'}`}
            >
              <LayoutDashboard size={20} /> Dashboard
            </button>
          </li>
          <li>
            <button 
              onClick={() => setCurrentPage('pemeriksaan')}
              className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl transition-all ${currentPage === 'pemeriksaan' ? 'bg-white/20 font-semibold' : 'hover:bg-white/10 opacity-80'}`}
            >
              <ClipboardList size={20} /> Pemeriksaan
            </button>
          </li>
          <li>
            <button 
              onClick={() => setCurrentPage('riwayat')}
              className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl transition-all ${currentPage === 'riwayat' ? 'bg-white/20 font-semibold' : 'hover:bg-white/10 opacity-80'}`}
            >
              <History size={20} /> Riwayat
            </button>
          </li>
        </ul>
      </nav>

      <div className="p-6 mt-auto">
        <div className="flex items-center gap-3 mb-6 p-3 bg-white/10 rounded-xl">
          <div className="w-10 h-10 rounded-full bg-blue-300 flex items-center justify-center text-blue-900 font-bold">
            BS
          </div>
          <div>
            <p className="text-sm font-semibold">dr. Budi Santoso</p>
            <p className="text-xs opacity-70">Spesialis Mata</p>
          </div>
        </div>
        <button 
          onClick={handleLogout}
          className="w-full flex items-center gap-3 px-4 py-3 rounded-xl hover:bg-red-500/20 text-red-100 transition-all border border-red-400/30"
        >
          <LogOut size={20} /> Keluar
        </button>
      </div>
    </div>
  );

  // --- PAGES ---

  if (currentPage === 'login') {
    return (
      <div className="flex h-screen bg-white font-['Inter']">
        <div className="hidden lg:flex lg:w-1/2 bg-gradient-to-br from-[#1565C0] to-[#42A5F5] items-center justify-center p-12 text-white relative overflow-hidden">
          <div className="absolute top-0 right-0 -mr-20 -mt-20 w-80 h-80 bg-white/10 rounded-full blur-3xl"></div>
          <div className="absolute bottom-0 left-0 -ml-20 -mb-20 w-80 h-80 bg-blue-900/20 rounded-full blur-3xl"></div>
          
          <div className="relative text-center max-w-md">
            <div className="bg-white p-6 rounded-3xl inline-block mb-8 shadow-2xl">
              <Eye className="text-[#1565C0]" size={64} />
            </div>
            <h1 className="text-5xl font-bold mb-4">GlaucoScan</h1>
            <p className="text-xl font-light opacity-90 leading-relaxed">
              Sistem Deteksi Glaukoma Berbasis AI Terintegrasi RS Mata Sejahtera
            </p>
          </div>
        </div>

        <div className="w-full lg:w-1/2 flex items-center justify-center p-8">
          <div className="max-w-md w-full">
            <h2 className="text-3xl font-bold text-gray-900 mb-2">Selamat Datang</h2>
            <p className="text-gray-500 mb-8">Silakan masuk ke akun medis Anda</p>
            
            <form onSubmit={handleLogin} className="space-y-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Email</label>
                <input 
                  type="email" 
                  required
                  className="w-full px-4 py-3 rounded-xl border border-gray-200 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition-all"
                  placeholder="dokter@rsmata.id"
                />
              </div>
              <div className="relative">
                <label className="block text-sm font-medium text-gray-700 mb-2">Password</label>
                <input 
                  type={showPassword ? "text" : "password"} 
                  required
                  className="w-full px-4 py-3 rounded-xl border border-gray-200 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition-all"
                  placeholder="••••••••"
                />
                <button 
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-4 top-10 text-gray-400 hover:text-gray-600"
                >
                  {showPassword ? <EyeOff size={20} /> : <EyeIcon size={20} />}
                </button>
              </div>
              
              <button 
                type="submit"
                disabled={loading}
                className="w-full bg-[#1565C0] text-white py-4 rounded-xl font-semibold shadow-lg hover:bg-blue-700 active:scale-[0.98] transition-all flex items-center justify-center gap-2"
              >
                {loading ? <Loader2 className="animate-spin" size={20} /> : "Masuk"}
              </button>
            </form>
            
            <p className="mt-8 text-center text-sm text-gray-400">
              © 2025 RS Mata Sejahtera IT Division. All rights reserved.
            </p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#F8FAFF] font-['Inter'] flex">
      <Sidebar />
      
      <main className="flex-1 ml-64 p-8">
        
        {/* DASHBOARD PAGE */}
        {currentPage === 'dashboard' && (
          <div className="animate-in fade-in duration-500">
            <div className="mb-8">
              <h1 className="text-2xl font-bold text-gray-900">Ringkasan Aktivitas</h1>
              <p className="text-gray-500">Selamat pagi, dr. Budi Santoso</p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-10">
              {dashboardStats.map((stat, i) => (
                <div key={i} className="bg-white p-6 rounded-3xl shadow-sm flex items-center gap-5 border border-gray-100">
                  <div className={`${stat.color} p-4 rounded-2xl text-white shadow-lg shadow-${stat.color.split('-')[1]}-200`}>
                    <stat.icon size={28} className={stat.title === 'Sedang Diproses ML' ? 'animate-spin' : ''} />
                  </div>
                  <div>
                    <p className="text-gray-500 text-sm font-medium">{stat.title}</p>
                    <p className="text-3xl font-bold text-gray-900">{stat.value}</p>
                  </div>
                </div>
              ))}
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
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
                                onClick={startExamination}
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

              <div className="space-y-6">
                <div className="bg-white p-6 rounded-3xl shadow-sm border border-gray-100">
                  <h2 className="font-bold text-gray-900 mb-4">Sedang Diproses ML</h2>
                  <div className="space-y-4">
                    {[
                      { name: 'Rudy Hartono', time: '1 menit lalu' },
                      { name: 'Maya Sari', time: 'Baru saja' }
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

                <div className="bg-gradient-to-br from-[#1565C0] to-[#42A5F5] p-6 rounded-3xl text-white">
                  <div className="flex justify-between items-start mb-4">
                    <Info size={24} />
                    <button className="text-white/60 hover:text-white"><MoreVertical size={20} /></button>
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
        )}

        {/* PEMERIKSAAN PAGE (STEPPER) */}
        {currentPage === 'pemeriksaan' && (
          <div className="max-w-4xl mx-auto animate-in slide-in-from-bottom-4 duration-500">
            <div className="mb-8 flex items-center gap-4">
              <button onClick={() => setCurrentPage('dashboard')} className="p-2 hover:bg-gray-100 rounded-full">
                <ArrowLeft size={24} />
              </button>
              <div>
                <h1 className="text-2xl font-bold text-gray-900">Alur Deteksi AI</h1>
                <p className="text-gray-500 text-sm">Pemeriksaan Pasien ID #3392</p>
              </div>
            </div>

            {/* Stepper Header */}
            <div className="flex items-center justify-between mb-12 relative px-10">
              <div className="absolute top-1/2 left-0 w-full h-1 bg-gray-200 -translate-y-1/2 -z-10"></div>
              <div className={`absolute top-1/2 left-0 h-1 bg-blue-600 -translate-y-1/2 -z-10 transition-all duration-500`} style={{width: `${(examStep - 1) * 50}%`}}></div>
              
              {[1, 2, 3].map((s) => (
                <div key={s} className="flex flex-col items-center gap-3">
                  <div className={`w-12 h-12 rounded-full flex items-center justify-center font-bold text-lg transition-all shadow-lg ${examStep >= s ? 'bg-blue-600 text-white scale-110' : 'bg-white text-gray-400 border-2 border-gray-200'}`}>
                    {examStep > s ? <CheckCircle size={24} /> : s}
                  </div>
                  <span className={`text-sm font-semibold ${examStep >= s ? 'text-blue-600' : 'text-gray-400'}`}>
                    {s === 1 ? 'Info Pasien' : s === 2 ? 'Upload Gambar' : 'Hasil Deteksi'}
                  </span>
                </div>
              ))}
            </div>

            {/* Step 1: Info Pasien */}
            {examStep === 1 && (
              <div className="bg-white p-8 rounded-3xl shadow-sm border border-gray-100">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-8 mb-10">
                  <div className="space-y-6">
                    <div>
                      <h3 className="text-xs uppercase text-gray-400 font-bold mb-3 tracking-widest">Data Personal</h3>
                      <div className="p-4 bg-gray-50 rounded-2xl space-y-3">
                        <div className="flex justify-between">
                          <span className="text-gray-500">Nama Lengkap</span>
                          <span className="font-bold">Andi Wijaya</span>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-gray-500">Usia / Gender</span>
                          <span className="font-bold">35 Th / Laki-laki</span>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-gray-500">ID Medis</span>
                          <span className="font-bold text-blue-600">#PX-2025-009</span>
                        </div>
                      </div>
                    </div>
                    <div>
                      <h3 className="text-xs uppercase text-gray-400 font-bold mb-3 tracking-widest">Informasi Janji</h3>
                      <div className="p-4 bg-gray-50 rounded-2xl space-y-3">
                        <div className="flex items-center gap-3">
                          <Calendar size={18} className="text-blue-500" />
                          <span className="font-medium text-gray-700">Senin, 3 Maret 2025</span>
                        </div>
                        <div className="flex items-center gap-3">
                          <Clock size={18} className="text-blue-500" />
                          <span className="font-medium text-gray-700">09:00 WIB</span>
                        </div>
                        <div className="flex items-center gap-3">
                          <User size={18} className="text-blue-500" />
                          <span className="font-medium text-gray-700">dr. Budi Santoso</span>
                        </div>
                      </div>
                    </div>
                  </div>
                  <div>
                    <h3 className="text-xs uppercase text-gray-400 font-bold mb-3 tracking-widest">Keluhan Utama</h3>
                    <div className="p-6 bg-blue-50 text-blue-800 rounded-3xl min-h-[160px] italic relative overflow-hidden">
                      <div className="absolute top-0 right-0 p-4 opacity-10"><FileText size={80} /></div>
                      "Mata sering terasa kabur saat malam hari, terkadang melihat lingkaran pelangi di sekitar lampu jalan. Akhir-akhir ini sering sakit kepala di bagian depan."
                    </div>
                    <div className="mt-6 flex items-start gap-3 text-sm text-gray-500 p-4 border border-dashed border-gray-200 rounded-2xl">
                      <Info size={20} className="text-orange-400 shrink-0" />
                      Pasien memiliki riwayat tekanan darah tinggi (Hipertensi) sejak 2 tahun lalu.
                    </div>
                  </div>
                </div>
                <button 
                  onClick={() => setExamStep(2)}
                  className="w-full py-4 bg-[#1565C0] text-white rounded-2xl font-bold shadow-lg hover:bg-blue-700 active:scale-[0.99] transition-all flex items-center justify-center gap-3"
                >
                  Mulai Pemeriksaan <ChevronRight size={20} />
                </button>
              </div>
            )}

            {/* Step 2: Upload */}
            {examStep === 2 && (
              <div className="bg-white p-8 rounded-3xl shadow-sm border border-gray-100">
                <div className="mb-10">
                  <label className="block text-sm font-bold text-gray-700 mb-4">Upload Foto Retina (Fundus)</label>
                  <div className="border-2 border-dashed border-gray-200 rounded-3xl p-12 text-center hover:border-blue-400 hover:bg-blue-50/50 transition-all cursor-pointer group">
                    <div className="bg-blue-100 w-20 h-20 rounded-full flex items-center justify-center mx-auto mb-4 group-hover:scale-110 transition-transform">
                      <Upload size={32} className="text-blue-600" />
                    </div>
                    <p className="text-lg font-bold text-gray-900 mb-1">Pilih gambar atau tarik ke sini</p>
                    <p className="text-sm text-gray-400">Dukung file JPG, PNG, atau TIFF (Maks. 10MB)</p>
                    <div className="mt-6 grid grid-cols-3 gap-4 max-w-sm mx-auto">
                      <div className="h-20 bg-gray-100 rounded-xl relative overflow-hidden flex items-center justify-center">
                        <img src="https://picsum.photos/seed/eye1/200" className="object-cover w-full h-full opacity-50" />
                        <span className="absolute text-[10px] bg-black/60 text-white px-2 py-0.5 rounded-full font-bold">PREVIEW</span>
                      </div>
                      <div className="h-20 border-2 border-dashed border-gray-200 rounded-xl flex items-center justify-center text-gray-300">
                        <Upload size={16} />
                      </div>
                    </div>
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-8 mb-10">
                  <div className="space-y-6">
                    <div>
                      <label className="block text-sm font-bold text-gray-700 mb-3">Sisi Mata</label>
                      <div className="grid grid-cols-3 gap-3">
                        {['Kiri', 'Kanan', 'Keduanya'].map(opt => (
                          <button key={opt} className={`py-3 px-4 rounded-xl text-sm font-semibold border-2 transition-all ${opt === 'Kiri' ? 'border-blue-600 bg-blue-50 text-blue-600' : 'border-gray-100 text-gray-500 hover:border-gray-200'}`}>
                            {opt}
                          </button>
                        ))}
                      </div>
                    </div>
                    <div>
                      <label className="block text-sm font-bold text-gray-700 mb-3">Model Kamera / Alat</label>
                      <input type="text" placeholder="Contoh: Topcon TRC-NW8" className="w-full px-4 py-3 rounded-xl border border-gray-200 focus:ring-2 focus:ring-blue-500 outline-none" defaultValue="Canon CR-2 AF" />
                    </div>
                  </div>
                  <div>
                    <label className="block text-sm font-bold text-gray-700 mb-3">Catatan Pengambilan (Opsional)</label>
                    <textarea className="w-full px-4 py-3 rounded-xl border border-gray-200 focus:ring-2 focus:ring-blue-500 outline-none h-[126px]" placeholder="Misal: Cahaya redup karena pupil tidak melebar maksimal"></textarea>
                  </div>
                </div>

                {uploadProgress > 0 && (
                  <div className="mb-6">
                    <div className="flex justify-between text-xs font-bold text-blue-600 mb-2">
                      <span>MENGUPLOAD DATA KE CLOUD...</span>
                      <span>{uploadProgress}%</span>
                    </div>
                    <div className="h-2 bg-gray-100 rounded-full overflow-hidden">
                      <div className="h-full bg-blue-600 transition-all duration-300" style={{width: `${uploadProgress}%`}}></div>
                    </div>
                  </div>
                )}

                <button 
                  onClick={handleUpload}
                  disabled={uploadProgress > 0}
                  className="w-full py-4 bg-[#1565C0] text-white rounded-2xl font-bold shadow-lg hover:bg-blue-700 active:scale-[0.99] transition-all flex items-center justify-center gap-3 disabled:opacity-50"
                >
                  Upload & Analisis Sekarang <Search size={20} />
                </button>
              </div>
            )}

            {/* Step 3: Hasil */}
            {examStep === 3 && (
              <div className="animate-in fade-in zoom-in-95 duration-700">
                {mlLoading ? (
                  <div className="bg-white p-20 rounded-3xl shadow-sm border border-gray-100 flex flex-col items-center justify-center text-center">
                    <div className="relative mb-8">
                      <div className="w-24 h-24 border-8 border-blue-50 border-t-blue-600 rounded-full animate-spin"></div>
                      <div className="absolute inset-0 flex items-center justify-center">
                        <Eye className="text-blue-200" size={32} />
                      </div>
                    </div>
                    <h2 className="text-2xl font-bold text-gray-900 mb-2">Model sedang menganalisis...</h2>
                    <p className="text-gray-500 max-w-sm">
                      Sistem kami sedang memproses segmentasi cakram optik dan menghitung perbandingan cup-to-disc.
                    </p>
                  </div>
                ) : (
                  <div className="space-y-6">
                    {/* Demo Toggle */}
                    <div className="flex bg-gray-200 p-1 rounded-2xl w-fit mx-auto shadow-inner">
                      <button onClick={() => setSelectedResult('NORMAL')} className={`px-6 py-2 rounded-xl text-sm font-bold transition-all ${selectedResult === 'NORMAL' ? 'bg-white shadow-md text-green-600' : 'text-gray-500'}`}>Demo: NORMAL</button>
                      <button onClick={() => setSelectedResult('GLAUKOMA')} className={`px-6 py-2 rounded-xl text-sm font-bold transition-all ${selectedResult === 'GLAUKOMA' ? 'bg-white shadow-md text-red-600' : 'text-gray-500'}`}>Demo: GLAUKOMA</button>
                    </div>

                    <div className="bg-white p-8 rounded-3xl shadow-sm border border-gray-100">
                      <div className="flex flex-col md:flex-row gap-8 items-center mb-10">
                        <div className={`p-8 rounded-[40px] flex flex-col items-center justify-center min-w-[240px] shadow-lg shadow-gray-100 border-2 ${selectedResult === 'NORMAL' ? 'bg-green-50 border-green-200' : 'bg-red-50 border-red-200'}`}>
                          <p className="text-xs font-black uppercase tracking-widest text-gray-400 mb-2">Hasil Prediksi AI</p>
                          <h2 className={`text-4xl font-black mb-1 ${selectedResult === 'NORMAL' ? 'text-green-700' : 'text-red-700'}`}>{selectedResult}</h2>
                          <div className={`flex items-center gap-1 font-bold ${selectedResult === 'NORMAL' ? 'text-green-600' : 'text-red-600'}`}>
                            {selectedResult === 'NORMAL' ? <CheckCircle size={18} /> : <AlertCircle size={18} />}
                            {selectedResult === 'NORMAL' ? 'Kesehatan Baik' : 'Tanda Glaukoma'}
                          </div>
                        </div>

                        <div className="flex-1 w-full">
                          <div className="flex justify-between mb-2 items-end">
                            <div>
                              <p className="text-sm font-bold text-gray-500">Tingkat Kepercayaan (Confidence)</p>
                              <p className="text-3xl font-black text-gray-900">{selectedResult === 'NORMAL' ? '92' : '85'}%</p>
                            </div>
                            <span className="text-xs font-bold text-gray-400 bg-gray-50 px-3 py-1 rounded-full border border-gray-100">v4.2 PRO MODEL</span>
                          </div>
                          <div className="h-4 bg-gray-100 rounded-full overflow-hidden mb-4">
                            <div className={`h-full transition-all duration-1000 ${selectedResult === 'NORMAL' ? 'bg-green-500' : 'bg-red-500'}`} style={{width: selectedResult === 'NORMAL' ? '92%' : '85%'}}></div>
                          </div>
                          <p className="text-xs text-gray-400 italic">
                            Waktu pemrosesan: <span className="text-gray-900 font-semibold">1.24 detik</span> pada server GPU-Edge.
                          </p>
                        </div>
                      </div>

                      <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                        <div>
                          <h3 className="text-sm font-bold text-gray-700 mb-4 flex items-center gap-2">
                            <Info size={16} className="text-blue-500" /> Distribusi Probabilitas
                          </h3>
                          <div className="h-64">
                            <ResponsiveContainer width="100%" height="100%">
                              <PieChart>
                                <Pie
                                  data={pieData}
                                  innerRadius={60}
                                  outerRadius={80}
                                  paddingAngle={5}
                                  dataKey="value"
                                >
                                  {pieData.map((entry, index) => (
                                    <Cell key={`cell-${index}`} fill={index === 0 ? COLORS.normal.hex : COLORS.glaucoma.hex} />
                                  ))}
                                </Pie>
                                <Tooltip />
                                <Legend verticalAlign="bottom" height={36}/>
                              </PieChart>
                            </ResponsiveContainer>
                          </div>
                        </div>
                        <div>
                          <h3 className="text-sm font-bold text-gray-700 mb-4 flex items-center gap-2">
                            <Eye size={16} className="text-blue-500" /> Visualisasi Fitur AI
                          </h3>
                          <div className="grid grid-cols-2 gap-3">
                            <div className="space-y-2">
                              <div className="aspect-square bg-gray-100 rounded-2xl overflow-hidden border border-gray-100">
                                <img src="https://picsum.photos/seed/retina/400" className="object-cover w-full h-full" alt="Retina" />
                              </div>
                              <p className="text-[10px] text-center font-bold text-gray-400 uppercase tracking-tighter">Foto Retina Orisinal</p>
                            </div>
                            <div className="space-y-2">
                              <div className="aspect-square bg-gray-100 rounded-2xl overflow-hidden border border-gray-100 relative">
                                <img src="https://picsum.photos/seed/heatmap/400" className="object-cover w-full h-full opacity-60 contrast-150" alt="Heatmap" />
                                <div className="absolute inset-0 bg-gradient-to-tr from-blue-500/30 to-red-500/50 mix-blend-overlay"></div>
                              </div>
                              <p className="text-[10px] text-center font-bold text-gray-400 uppercase tracking-tighter">Heatmap (Grad-CAM)</p>
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>

                    <div className="flex gap-4">
                      <button className="flex-1 py-4 bg-white border-2 border-gray-100 rounded-2xl font-bold text-gray-600 hover:bg-gray-50 flex items-center justify-center gap-2 transition-all">
                        <Download size={20} /> Download PDF
                      </button>
                      <button 
                        onClick={() => setCurrentPage('dashboard')}
                        className="flex-[2] py-4 bg-[#1565C0] text-white rounded-2xl font-bold shadow-lg hover:bg-blue-700 active:scale-[0.99] transition-all"
                      >
                        Selesai & Simpan Rekam Medis
                      </button>
                    </div>
                  </div>
                )}
              </div>
            )}
          </div>
        )}

        {/* RIWAYAT PAGE */}
        {currentPage === 'riwayat' && (
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
              <div className="p-6 border-b border-gray-50 flex flex-wrap gap-4 items-center">
                <div className="relative flex-1 min-w-[300px]">
                  <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
                  <input type="text" placeholder="Cari nama pasien atau ID..." className="w-full pl-12 pr-4 py-2.5 rounded-xl border border-gray-200 outline-none focus:ring-2 focus:ring-blue-500" />
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
                        <td className="px-6 py-4 text-center text-gray-400 text-sm font-bold">{i+1}</td>
                        <td className="px-6 py-4">
                          <div className="flex items-center gap-3">
                            <div className="w-8 h-8 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center text-xs font-bold">
                              {data.name.split(' ').map(n => n[0]).join('')}
                            </div>
                            <span className="font-bold text-gray-900">{data.name}</span>
                          </div>
                        </td>
                        <td className="px-6 py-4 text-gray-500 text-sm">{data.date}</td>
                        <td className="px-6 py-4 text-gray-600 text-sm">{data.eye}</td>
                        <td className="px-6 py-4">
                          <span className={`px-3 py-1 rounded-full text-[10px] font-black tracking-widest ${data.result === 'NORMAL' ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}`}>
                            {data.result}
                          </span>
                        </td>
                        <td className="px-6 py-4">
                          <div className="flex items-center gap-2">
                            <div className="flex-1 h-1.5 bg-gray-100 rounded-full min-w-[60px]">
                              <div className={`h-full rounded-full ${data.conf > 90 ? 'bg-green-500' : 'bg-blue-500'}`} style={{width: `${data.conf}%`}}></div>
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

              <div className="p-6 bg-gray-50 border-t border-gray-100 flex justify-between items-center">
                <p className="text-sm text-gray-500">Menampilkan <span className="font-bold text-gray-900">10</span> dari <span className="font-bold text-gray-900">142</span> data</p>
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
          </div>
        )}

        {/* MODAL DETAIL RIWAYAT */}
        {selectedHistory && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
            <div className="absolute inset-0 bg-blue-900/60 backdrop-blur-sm" onClick={() => setSelectedHistory(null)}></div>
            <div className="bg-white w-full max-w-4xl rounded-[32px] shadow-2xl relative overflow-hidden flex flex-col max-h-[90vh] animate-in zoom-in-95 duration-300">
              <div className="p-8 border-b border-gray-100 flex justify-between items-center">
                <div>
                  <p className="text-xs font-black text-blue-600 uppercase tracking-widest mb-1">Arsip Medis #{selectedHistory.id}</p>
                  <h2 className="text-2xl font-bold text-gray-900">{selectedHistory.name}</h2>
                </div>
                <button onClick={() => setSelectedHistory(null)} className="p-2 hover:bg-gray-100 rounded-full text-gray-400"><LogOut className="rotate-180" size={24} /></button>
              </div>
              
              <div className="p-8 overflow-y-auto flex-1 bg-gray-50/50">
                <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                  <div className="lg:col-span-2 space-y-8">
                    <div className="bg-white p-6 rounded-3xl border border-gray-100 shadow-sm">
                      <h3 className="font-bold text-gray-900 mb-6 flex items-center gap-2">
                        <EyeIcon size={20} className="text-blue-600" /> Hasil Analisis AI
                      </h3>
                      <div className="flex gap-6 items-center">
                        <div className={`p-6 rounded-2xl flex flex-col items-center justify-center min-w-[160px] ${selectedHistory.result === 'NORMAL' ? 'bg-green-50 text-green-700 border border-green-100' : 'bg-red-50 text-red-700 border border-red-100'}`}>
                          <p className="text-[10px] font-black uppercase mb-1 opacity-50">Status</p>
                          <span className="text-2xl font-black">{selectedHistory.result}</span>
                        </div>
                        <div className="flex-1">
                          <div className="flex justify-between mb-2">
                            <span className="text-sm font-bold text-gray-500">Confidence Score</span>
                            <span className="text-sm font-black text-gray-900">{selectedHistory.conf}%</span>
                          </div>
                          <div className="h-3 bg-gray-100 rounded-full overflow-hidden">
                            <div className={`h-full ${selectedHistory.result === 'NORMAL' ? 'bg-green-500' : 'bg-red-500'}`} style={{width: `${selectedHistory.conf}%`}}></div>
                          </div>
                        </div>
                      </div>

                      <div className="mt-8 grid grid-cols-2 gap-4">
                        <div className="space-y-2">
                          <img src="https://picsum.photos/seed/hist1/400" className="w-full aspect-video object-cover rounded-2xl border border-gray-100" />
                          <p className="text-[10px] text-center font-bold text-gray-400">FUNDUS PHOTOGRAPH</p>
                        </div>
                        <div className="space-y-2">
                          <div className="relative rounded-2xl overflow-hidden border border-gray-100">
                            <img src="https://picsum.photos/seed/hist2/400" className="w-full aspect-video object-cover opacity-60" />
                            <div className="absolute inset-0 bg-gradient-to-tr from-blue-500/30 to-red-500/50 mix-blend-overlay"></div>
                          </div>
                          <p className="text-[10px] text-center font-bold text-gray-400">GRAD-CAM HEATMAP</p>
                        </div>
                      </div>
                    </div>

                    <div className="bg-white p-6 rounded-3xl border border-gray-100 shadow-sm">
                      <h3 className="font-bold text-gray-900 mb-4 flex items-center gap-2">
                        <FileText size={20} className="text-blue-600" /> Diagnosis Dokter
                      </h3>
                      <div className="p-5 bg-blue-50/50 border border-blue-100 rounded-2xl text-blue-900 italic text-sm leading-relaxed">
                        "Berdasarkan analisis AI dan pemeriksaan fisik, struktur saraf mata masih dalam batas normal. Namun, terdapat riwayat keluarga glaukoma. Disarankan kontrol rutin 6 bulan sekali dan menjaga pola makan sehat."
                      </div>
                      <div className="mt-4 flex justify-between items-center text-xs">
                        <span className="text-gray-400">Terakhir diperbarui: 03/03/2025</span>
                        <span className="font-bold text-blue-600 underline cursor-pointer">Edit Diagnosis</span>
                      </div>
                    </div>
                  </div>

                  <div className="space-y-6">
                    <div className="bg-white p-6 rounded-3xl border border-gray-100 shadow-sm">
                      <h3 className="text-xs font-black text-gray-400 uppercase tracking-widest mb-4">Info Pasien</h3>
                      <div className="space-y-4">
                        <div>
                          <p className="text-[10px] text-gray-400 font-bold uppercase">Nama</p>
                          <p className="font-bold text-gray-900">{selectedHistory.name}</p>
                        </div>
                        <div>
                          <p className="text-[10px] text-gray-400 font-bold uppercase">Tanggal Pemeriksaan</p>
                          <p className="font-bold text-gray-900">{selectedHistory.date}</p>
                        </div>
                        <div>
                          <p className="text-[10px] text-gray-400 font-bold uppercase">Mata</p>
                          <p className="font-bold text-gray-900">{selectedHistory.eye}</p>
                        </div>
                        <div>
                          <p className="text-[10px] text-gray-400 font-bold uppercase">Dokter Pemeriksa</p>
                          <p className="font-bold text-gray-900">{selectedHistory.doctor}</p>
                        </div>
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
        )}

      </main>
    </div>
  );
};

export default App;