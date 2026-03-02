import React, { useState, useEffect } from 'react';
import { 
  Eye, 
  EyeOff, 
  Loader2, 
  ShieldCheck, 
  Activity, 
  Stethoscope, 
  ChevronRight,
  Database,
  Lock
} from 'lucide-react';

// --- Komponen Dashboard Mockup (untuk simulasi navigasi) ---
const AdminDashboard = ({ onLogout }) => (
  <div className="flex flex-col items-center justify-center h-screen bg-slate-50 p-6 text-center">
    <div className="bg-white p-8 rounded-3xl shadow-xl max-w-md w-full">
      <div className="w-20 h-20 bg-blue-100 rounded-2xl flex items-center justify-center mx-auto mb-6 text-blue-600">
        <Database size={40} />
      </div>
      <h1 className="text-2xl font-bold text-slate-800 mb-2">Admin Dashboard</h1>
      <p className="text-slate-500 mb-8">Selamat datang kembali, Administrator. Data sistem terpantau stabil.</p>
      <button 
        onClick={onLogout}
        className="w-full py-3 bg-slate-800 text-white rounded-xl font-medium hover:bg-slate-900 transition-colors"
      >
        Log Out
      </button>
    </div>
  </div>
);

const LabsDashboard = ({ onLogout }) => (
  <div className="flex flex-col items-center justify-center h-screen bg-slate-50 p-6 text-center">
    <div className="bg-white p-8 rounded-3xl shadow-xl max-w-md w-full">
      <div className="w-20 h-20 bg-emerald-100 rounded-2xl flex items-center justify-center mx-auto mb-6 text-emerald-600">
        <Activity size={40} />
      </div>
      <h1 className="text-2xl font-bold text-slate-800 mb-2">Lab Analytics</h1>
      <p className="text-slate-500 mb-8">Selamat datang, Teknisi Lab. 12 hasil scan AI baru menunggu verifikasi.</p>
      <button 
        onClick={onLogout}
        className="w-full py-3 bg-emerald-600 text-white rounded-xl font-medium hover:bg-emerald-700 transition-colors"
      >
        Log Out
      </button>
    </div>
  </div>
);

// --- Komponen Login Utama ---
const Login = ({ onLoginSuccess }) => {
  const [loading, setLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [role, setRole] = useState('admin');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    setLoading(true);

    // Simulasi proses autentikasi
    setTimeout(() => {
      setLoading(false);
      onLoginSuccess(role);
    }, 1500);
  };

  return (
    <div className="flex min-h-screen bg-slate-50 font-sans selection:bg-blue-100">
      
      {/* Panel Kiri: Branding & Visual */}
      <div className="hidden lg:flex lg:w-[55%] relative overflow-hidden bg-[#0f172a] items-center justify-center p-12">
        {/* Animated Background Elements */}
        <div className="absolute top-[-10%] left-[-10%] w-[50%] h-[50%] bg-blue-600/20 rounded-full blur-[120px]"></div>
        <div className="absolute bottom-[-10%] right-[-10%] w-[40%] h-[40%] bg-cyan-500/10 rounded-full blur-[100px]"></div>
        <div className="absolute inset-0 opacity-10" style={{ backgroundImage: 'radial-gradient(#ffffff 1px, transparent 1px)', size: '40px 40px', backgroundSize: '30px 30px' }}></div>

        <div className="relative z-10 max-w-xl">
          <div className="mb-10 inline-flex items-center gap-3 px-4 py-2 bg-white/5 border border-white/10 rounded-full backdrop-blur-md">
            <ShieldCheck className="text-blue-400" size={18} />
            <span className="text-blue-100 text-sm font-medium tracking-wide">AI-Powered Eye Diagnostics v2.4</span>
          </div>
          
          <h1 className="text-6xl font-extrabold text-white mb-6 leading-tight">
            Presisi AI untuk <span className="text-transparent bg-clip-text bg-gradient-to-r from-blue-400 to-cyan-300">Kesehatan Mata.</span>
          </h1>
          
          <p className="text-lg text-slate-400 mb-12 leading-relaxed">
            GlaucoScan membantu praktisi medis mendeteksi indikasi glaukoma dengan akurasi 98.7% melalui integrasi Deep Learning terkini.
          </p>

          <div className="grid grid-cols-2 gap-6 text-white">
            <div className="p-4 rounded-2xl bg-white/5 border border-white/10 backdrop-blur-sm">
              <div className="text-blue-400 mb-2 font-bold text-xl font-mono">200k+</div>
              <div className="text-xs text-slate-400 uppercase tracking-widest font-semibold text-nowrap">Analisis Berhasil</div>
            </div>
            <div className="p-4 rounded-2xl bg-white/5 border border-white/10 backdrop-blur-sm">
              <div className="text-cyan-400 mb-2 font-bold text-xl font-mono">Real-time</div>
              <div className="text-xs text-slate-400 uppercase tracking-widest font-semibold text-nowrap">Processing</div>
            </div>
          </div>
        </div>
        
        {/* Decorative Eye Graphic */}
        <div className="absolute bottom-10 left-12 flex items-center gap-3 text-white/20">
            <Activity size={40} />
            <div className="h-8 w-[1px] bg-white/10"></div>
            <span className="text-sm font-mono tracking-tighter italic">RS Mata Sejahtera Digital Ecosystem</span>
        </div>
      </div>

      {/* Panel Kanan: Form Login */}
      <div className="w-full lg:w-[45%] flex items-center justify-center p-6 md:p-12 lg:p-20 bg-white">
        <div className="w-full max-w-md">
          <div className="mb-10">
            <div className="w-14 h-14 bg-blue-600 rounded-2xl flex items-center justify-center mb-6 shadow-lg shadow-blue-200">
                <Eye className="text-white" size={32} />
            </div>
            <h2 className="text-3xl font-bold text-slate-900 mb-2 italic">GlaucoScan</h2>
            <p className="text-slate-500">Selamat datang kembali. Silakan akses portal Anda.</p>
          </div>

          <form onSubmit={handleSubmit} className="space-y-5">
            {/* Role Switcher (Segmented Control) */}
            <div className="p-1 bg-slate-100 rounded-xl flex mb-8">
              <button
                type="button"
                onClick={() => setRole('admin')}
                className={`flex-1 flex items-center justify-center gap-2 py-2.5 rounded-lg text-sm font-semibold transition-all ${
                  role === 'admin' ? 'bg-white text-blue-600 shadow-sm' : 'text-slate-500 hover:text-slate-700'
                }`}
              >
                <Stethoscope size={16} /> Admin
              </button>
              <button
                type="button"
                onClick={() => setRole('labs')}
                className={`flex-1 flex items-center justify-center gap-2 py-2.5 rounded-lg text-sm font-semibold transition-all ${
                  role === 'labs' ? 'bg-white text-blue-600 shadow-sm' : 'text-slate-500 hover:text-slate-700'
                }`}
              >
                <Activity size={16} /> Lab Teknisi
              </button>
            </div>

            {/* Email Field */}
            <div className="space-y-2">
              <label className="text-sm font-semibold text-slate-700 ml-1">Email Institusi</label>
              <div className="relative group">
                <input
                  type="email"
                  required
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="nama@rsmata.id"
                  className="w-full pl-4 pr-4 py-3.5 bg-slate-50 border border-slate-200 rounded-xl focus:ring-4 focus:ring-blue-500/10 focus:border-blue-500 outline-none transition-all placeholder:text-slate-400 text-slate-700"
                />
              </div>
            </div>

            {/* Password Field */}
            <div className="space-y-2">
              <div className="flex justify-between items-center ml-1">
                <label className="text-sm font-semibold text-slate-700">Kata Sandi</label>
                <a href="#" className="text-xs font-medium text-blue-600 hover:underline">Lupa sandi?</a>
              </div>
              <div className="relative group">
                <input
                  type={showPassword ? 'text' : 'password'}
                  required
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••"
                  className="w-full pl-4 pr-12 py-3.5 bg-slate-50 border border-slate-200 rounded-xl focus:ring-4 focus:ring-blue-500/10 focus:border-blue-500 outline-none transition-all placeholder:text-slate-400 text-slate-700"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-4 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 transition-colors"
                >
                  {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                </button>
              </div>
            </div>

            {/* Submit Button */}
            <button
              type="submit"
              disabled={loading}
              className="w-full bg-blue-600 text-white py-4 rounded-xl font-bold text-lg shadow-xl shadow-blue-100 hover:bg-blue-700 active:scale-[0.99] transition-all flex items-center justify-center gap-3 disabled:opacity-70 disabled:cursor-not-allowed group mt-2"
            >
              {loading ? (
                <>
                  <Loader2 className="animate-spin" size={20} />
                  <span>Memverifikasi...</span>
                </>
              ) : (
                <>
                  <span>Masuk ke Portal</span>
                  <ChevronRight size={20} className="group-hover:translate-x-1 transition-transform" />
                </>
              )}
            </button>
          </form>

          {/* Footer Form */}
          <div className="mt-12 pt-8 border-t border-slate-100 flex flex-col items-center gap-4 text-center">
             <div className="flex items-center gap-2 text-slate-400 text-xs">
                <Lock size={12} />
                <span>Enkripsi AES-256 Bit Terjamin</span>
             </div>
             <p className="text-xs text-slate-400 max-w-[280px] leading-relaxed">
               © 2025 IT Division RS Mata Sejahtera. Sistem ini hanya untuk penggunaan personil resmi.
             </p>
          </div>
        </div>
      </div>
    </div>
  );
};

// --- App Component Entry Point ---
export default function App() {
  const [view, setView] = useState('login'); // 'login' | 'admin' | 'labs'

  const handleLoginSuccess = (role) => {
    setView(role === 'admin' ? 'admin' : 'labs');
  };

  const handleLogout = () => {
    setView('login');
  };

  return (
    <div className="min-h-screen">
      {view === 'login' && <Login onLoginSuccess={handleLoginSuccess} />}
      {view === 'admin' && <AdminDashboard onLogout={handleLogout} />}
      {view === 'labs' && <LabsDashboard onLogout={handleLogout} />}
    </div>
  );
}